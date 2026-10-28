# KKO / Plzeňský kraj

Statická participativní aplikace pro GitHub Pages. Zápisy odpovědí jdou do Supabase; RLS dovoluje veřejnosti pouze vkládat nové odpovědi. Aplikace dostává pouze veřejný publishable klíč, nikdy tajný klíč.

## Supabase

Projekt `KKO` je již připojen a databázové schéma je vytvořené. `config.js` obsahuje jeho Project URL a publishable key.

Aby fungoval administrátorský přehled:

1. V Supabase Dashboard → Authentication → Users vytvoř účet správce. Veřejné registrace ponech vypnuté.
2. Zkopíruj UUID tohoto uživatele.
3. V SQL Editoru spusť tento příkaz a nahraď hodnotu UUID:

   ```sql
   insert into private.admin_users (user_id) values ('UUID-SPRAVCE');
   ```

Pouze uživatelé uvedení v `private.admin_users` mohou po přihlášení číst odpovědi. Seznam je v neveřejném schématu.

## GitHub Pages

V GitHubu je potřeba vytvořit veřejné repository. Pak nahraj obsah této složky `outputs` do jeho kořene, včetně `index.html`, `config.js` a složky `supabase`.

1. V repozitáři otevři Settings → Pages.
2. Jako zdroj zvol `Deploy from a branch`, větev `main` a složku `/ (root)`, pak ulož.
3. Po dokončení nasazení otevři URL zobrazenou v Settings → Pages.
4. Přidej tuto URL v Supabase → Authentication → URL Configuration do povolených adres webu.

GitHub Free nabízí Pages pro veřejné repozitáře. `config.js` obsahuje veřejný publishable key, který je určený pro použití v prohlížeči. Nikdy do něj nevkládej `service_role`/secret key ani heslo.
