# Базове використання `hardLink`

Використання базових можливостей методу <code>hardLink</code>.

### Застосування рутини `hardLink` до файлів, які уже є хард лінками.

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

### Застосування рутини `hardLink` до файлів, які є софт лінками.

|Return|src is a soft link to|dst is a soft link to|throwing|resolvingSrcSoftLink|resolvingDstSoftLink|allowingMissed|allowingCycled|
|:----:|:-------------------:|:-------------------:|:------:|:------------------:|:------------------:|:------------:|:------------:|
|null  |nonexistent file     |                     |0       |d                   |                    |1             |1             |
|error |nonexistent file     |                     |1       |d                   |                    |1             |1             |
|null  |nonexistent file     |                     |0       |0                   |                    |1             |1             |
|error |nonexistent file     |                     |1       |0                   |                    |1             |1             |
|null  |nonexistent file     |                     |0       |1                   |                    |1             |1             |
|error |nonexistent file     |                     |1       |1                   |                    |1             |1             |
|null  |existing file        |                     |0       |0                   |                    |1             |1             |
|error |existing file        |                     |1       |0                   |                    |1             |1             |
|true  |existing file        |                     |d       |1                   |                    |1             |1             |
|null  |self                 |                     |0       |d                   |                    |1             |1             |
|error |self                 |                     |1       |d                   |                    |1             |1             |
|null  |self                 |                     |0       |0                   |                    |1             |1             |
|error |self                 |                     |1       |0                   |                    |1             |1             |
|null  |self                 |                     |0       |1                   |                    |1             |1             |
|error |self                 |                     |1       |1                   |                    |1             |1             |
