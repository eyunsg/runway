import { supabase } from "../lib/supabase";

async function testConnection() {
  const { data, error } = await supabase.auth.getSession();

  if (error) {
    console.error("❌ Supabase 연결 실패");
    console.error(error);
    return;
  }

  console.log("✅ Supabase 연결 성공");
}

testConnection();
