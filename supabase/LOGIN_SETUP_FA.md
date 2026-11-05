# فعال‌سازی ورود آنلاین SEN SPORT
این فایل‌ها UI ورود و ثبت‌نام را فراهم می‌کنند، اما اتصال تا تنظیم اطلاعات پروژه فعال نمی‌شود.

## تنظیم لازم (یک‌بار)
1. در https://supabase.com یک پروژه بسازید.
2. از Project Settings → API، Project URL و anon/public key را بردارید.
3. فایل `supabase-config.js` را باز کنید و دو مقدار جایگزین کنید.
4. در Supabase → SQL Editor، فایل `supabase/schema.sql` را اجرا کنید.
5. در Authentication → URL Configuration، آدرس GitHub Pages را به Site URL و Redirect URLs اضافه کنید.

## ورود
صفحه: https://hessarimehrdad-sys.github.io/Sen_sport/login.html
ثبت‌نام با ایمیل و رمز (حداقل ۸ کاراکتر) انجام می‌شود. ممکن است تأیید ایمیل لازم باشد.

## نکات امنیتی
- کلید service_role را هرگز در فایل‌های سایت قرار ندهید.
- ثبت‌نام به‌تنهایی نقش مربی ایجاد نمی‌کند؛ نقش‌ها باید توسط مدیر در پایگاه داده تعیین شوند.
- داشبورد فعلی هنوز به جداول Supabase متصل نشده و داده‌های قبلی localStorage را خودکار همگام نمی‌کند. این صفحه فقط Auth را برقرار می‌کند.
