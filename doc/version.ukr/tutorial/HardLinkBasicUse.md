# Базове використання `hardLink`

Використання базових можливостей методу <code>hardLink</code>.

Нехай маємо таку структуру файлів у файловій системі.

![Initial state of files](../../img/hardLink_startState.png)

У випадку створення хард лінка із опціями за замовчуванням відбудуться наступні зміни:

![Default hard linking](../../img/hardLink_defaultCase.png)

Файл dst стає хард лінком файла з даними Data1.

У випадку створення хард лінка із опціями breakingSrcHardLink:1 та breakingDstHardLink:0, отримаємо: 

![Hard linking with breakingSrcHardLink:1, breakingDstHardLink:0](../../img/hardLink_breakingSrcHardLink=1_Case.png)

Тобто не лише src стає хард лінком файла на котрий вказував і далі продовжує вказувати хард лінк dst, але й відбувається копіювання даних Data1. Дані Data2 видалені.

Якщо ж встановити опції breakingSrcHardLink:1, breakingDstHardLink:1, отримаємо:

![Hard linking with breakingSrcHardLink:1, breakingDstHardLink:1](../../img/hardLink_breakingSrcHardLink=1&&breakingDstHardLink=1_Case.png)

У цьому разі створюється новий файл на котрий вказують хард лінк src та dst. Дані у цей файл копіюються із файлу на який раніше вказував src.

Створення хард лінка з опціями breakingSrcHardLink:0, breakingDstHardLink:0 є забороненим.
