# طرح ورود امن و اتصال آنلاین SEN SPORT

## هدف
تبدیل نسخه فعلیِ ذخیره‌سازی مرورگر به سامانه چندکاربره با احراز هویت، نقش مربی/بازیکن، پایگاه داده و همگام‌سازی آنلاین.

## معماری پیشنهادی (MVP)
- Frontend: همین GitHub Pages (HTML/CSS/JS؛ فقط رابط کاربری).
- Backend/API: Supabase (Auth + PostgreSQL + Storage).
- ورود: ایمیل/رمز یا دعوت‌نامه؛ مربی حساب مدیریتی، بازیکن حساب محدود.
- داده‌ها: بازیکنان، جلسات تمرین، حضورها، شهریه‌ها، گزارش‌ها، پیام‌ها و فایل‌ها.
- امنیت: Row Level Security (RLS)؛ هر تیم فقط داده خودش را می‌بیند؛ بازیکن فقط پروفایل و داده‌های مجاز خود؛ مربی دسترسی مدیریتی تیم.
- فایل‌ها: تصاویر و رسیدها در Storage خصوصی؛ لینک موقت و کنترل دسترسی.
- پشتیبان‌گیری: خروجی دوره‌ای دیتابیس و سیاست نگهداری فایل‌ها.

## مدل داده اولیه
- teams(id, name, created_by)
- profiles(user_id, team_id, role, player_id)
- players(id, team_id, name, jersey_number, photo_path, active)
- sessions(id, team_id, session_date, title)
- attendance(id, session_id, player_id, status, note)
- fees(id, team_id, player_id, month, amount, receipt_path, status, approved_by, approved_at)
- performance_reports(id, team_id, player_id, report_date, content, author_id)
- messages(id, team_id, sender_id, recipient_id, body, created_at)
- media(id, team_id, player_id, storage_path, category, created_by)

## جریان‌ها
1. مربی توسط مدیر سامانه ایجاد/دعوت می‌شود؛ ثبت‌نام عمومی به نقش مربی دسترسی نمی‌دهد.
2. مربی تیم را می‌سازد و بازیکن را با دعوت امن به حساب مرتبط می‌کند.
3. بازیکن وارد می‌شود و فقط داده‌های مربوط به خودش/تیم طبق مجوز را می‌بیند.
4. مربی حضور را ثبت می‌کند و شهریه را بررسی و تأیید می‌کند.
5. تغییرات از API به دیتابیس ذخیره و بین دستگاه‌ها همگام می‌شود.

## مراحل اجرا
1. ساخت پروژه Supabase و تنظیم Auth، جدول‌ها و RLS.
2. تعریف سیاست‌های دسترسی و آزمایش با دو حساب مربی/بازیکن.
3. اتصال frontend به Supabase با کلید anon/public؛ هرگز service_role یا رمزها در HTML قرار نگیرند.
4. انتقال/ورود داده‌های localStorage با ابزار import و تأیید کاربر.
5. تست موبایل، خطاها، پشتیبان‌گیری و انتشار.

## هشدار نسخه فعلی
PIN پیش‌فرض 1234 و رمز ذخیره‌شده در localStorage امنیت واقعی نیستند؛ فقط مانع ظاهری‌اند. تا راه‌اندازی Backend، اطلاعات حساس یا واقعی در نسخه عمومی قرار ندهید. این فایل صرفاً نقشه اجراست و Backend را فعال نمی‌کند.
