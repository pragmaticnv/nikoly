import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://vggrimvjjzwmxvaqsbpb.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZnZ3JpbXZqanp3bXh2YXFzYnBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyNDM1NjQsImV4cCI6MjA4OTgxOTU2NH0.yLxpQ_WkckFrNAX7QRncWUfgbIW4RVhMxPF871tw60k';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
