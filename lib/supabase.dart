
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'https://xuzvixzgudjycuywwppu.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1enZpeHpndWRqeWN1eXd3cHB1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0NjQ5NzYxMCwiZXhwIjoyMDYyMDczNjEwfQ.vfsDcpR9KvFaZhA1zdUnXCS-8ozc_YHJcNIaT_FI9V4',
  );
}
