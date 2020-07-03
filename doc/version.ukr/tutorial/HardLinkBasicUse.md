# Базове використання `hardLink`

Використання базових можливостей методу <code>hardLink</code>.

Нехай маємо таку структуру файлів у файловій системі.

![Initial state of files](../../img/hardLink_startState.png)

У випадку створення хард лінка із опціями за замовчуванням відбудуться наступні зміни:

![Default hard linking](../../img/hardLink_defaultCase.png)

У випадку створення хард лінка із опціями breakingSrcHardLink:1 та breakingDstHardLink:0, отримаємо: 

![Hard linking with breakingSrcHardLink:1, breakingDstHardLink:0](../../img/hardLink_breakingSrcHardLink=1_Case.png)

Якщо ж встановити опції breakingSrcHardLink:1, breakingDstHardLink:1, отримаємо:

![Hard linking with breakingSrcHardLink:1, breakingDstHardLink:1](../../img/hardLink_breakingSrcHardLink=1&&breakingDstHardLink=1_Case.png)

Створення хард лінка з опціями breakingSrcHardLink:0, breakingDstHardLink:0 є забороненим.
