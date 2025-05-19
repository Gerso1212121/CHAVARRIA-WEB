import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:final_project/views/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xuzvixzgudjycuywwppu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1enZpeHpndWRqeWN1eXd3cHB1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ5NzYxMCwiZXhwIjoyMDYyMDczNjEwfQ.vfsDcpR9KvFaZhA1zdUnXCS-8ozc_YHJcNIaT_FI9V4',
  );

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}
