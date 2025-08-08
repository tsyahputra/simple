import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simple/cubit/user_cubit.dart';

class TwoFASetupPage extends StatefulWidget {
  const TwoFASetupPage({super.key});

  @override
  State<TwoFASetupPage> createState() => _TwoFASetupPageState();
}

class _TwoFASetupPageState extends State<TwoFASetupPage> {
  final TextEditingController _twoFACodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan 2FA')),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserFail) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          }
        },
        builder: (context, state) {
          if (state is UserLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TwoFASecretGenerated) {
            return _buildVerifyForm(
              context,
              state.twoFASecret.qrCodeUrl,
              state.twoFASecret.secret,
            );
          } else if (state is UserSubmitted) {
            return _buildRecoveryCodesDisplay(context);
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Aktifkan Otentikasi Dua Faktor (2FA) untuk meningkatkan keamanan akun Anda.',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Otentikasi menggunakan aplikasi Google Authenticator pada telepon pintar Anda.',
                    ),
                    SizedBox(height: 30.0),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserCubit>().generate2FASecret();
                      },
                      child: Text('Mulai Pengaturan 2FA'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildVerifyForm(
    BuildContext context,
    String qrCodeUrl,
    String secret,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Pindai QR Code ini dengan aplikasi Google Authenticator atau masukkan secret key secara manual.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20.0),
            Center(
              child: QrImageView(
                data: qrCodeUrl,
                version: QrVersions.auto,
                size: 200.0,
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Secret Key: $secret',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.copy),
              label: Text('Salin Secret Key'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: secret));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Secret Key disalin!')));
              },
            ),
            SizedBox(height: 30.0),
            TextField(
              controller: _twoFACodeController,
              decoration: InputDecoration(
                labelText: 'Masukkan Kode 2FA dari Google Authenticator anda',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<UserCubit>().verifyAndEnable2FA(
                  _twoFACodeController.text,
                );
              },
              child: Text('Verifikasi & Aktifkan 2FA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecoveryCodesDisplay(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '2FA berhasil diaktifkan',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Selesai'),
            ),
          ],
        ),
      ),
    );
  }
}
