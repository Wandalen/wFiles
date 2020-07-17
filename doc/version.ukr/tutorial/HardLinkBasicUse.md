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

У таблиці нижче наведені всі можливі очікувані результати виконання `hardLink` у випадку коли `src` та/або `dst` файли є софт лінками.

|Return|src is a                          |dst is a                          |throwing|resolvingSrcSoftLink|resolvingDstSoftLink|allowingMissed|allowingCycled|
|:----:|:--------------------------------:|:--------------------------------:|:------:|:------------------:|:------------------:|:------------:|:------------:|
|null  |soft link to nonexistent file     |terminal/nonexistent              |0       |d                   |d                   |1             |1             |
|error |soft link to nonexistent file     |terminal/nonexistent              |1       |d                   |d                   |1             |1             |
|null  |soft link to nonexistent file     |terminal/nonexistent              |0       |0                   |d                   |1             |1             |
|error |soft link to nonexistent file     |terminal/nonexistent              |1       |0                   |d                   |1             |1             |
|null  |soft link to nonexistent file     |terminal/nonexistent              |0       |1                   |d                   |1             |1             |
|error |soft link to nonexistent file     |terminal/nonexistent              |1       |1                   |d                   |1             |1             |
|null  |soft link to existing file        |terminal/nonexistent              |0       |0                   |d                   |1             |1             |
|error |soft link to existing file        |terminal/nonexistent              |1       |0                   |d                   |1             |1             |
|True  |soft link to existing file        |terminal/nonexistent              |d       |1                   |d                   |1             |1             |
|null  |soft link to self                 |terminal/nonexistent              |0       |d                   |d                   |1             |1             |
|error |soft link to self                 |terminal/nonexistent              |1       |d                   |d                   |1             |1             |
|null  |soft link to self                 |terminal/nonexistent              |0       |0                   |d                   |1             |1             |
|error |soft link to self                 |terminal/nonexistent              |1       |0                   |d                   |1             |1             |
|null  |soft link to self                 |terminal/nonexistent              |0       |1                   |d                   |1             |1             |
|error |soft link to self                 |terminal/nonexistent              |1       |1                   |d                   |1             |1             |
|||||||||
|True  |terminal file                     |soft link to nonexistent file     |0       |d                   |d                   |1             |1             |
|True  |terminal file                     |soft link to nonexistent file     |0       |d                   |0                   |1             |1             |
|True  |terminal file                     |soft link to nonexistent file     |0       |d                   |1                   |1             |1             |
|True  |terminal file                     |soft link to existing file        |0       |d                   |d                   |0             |0             |
|True  |terminal file                     |soft link to existing file        |0       |d                   |0                   |0             |0             |
|True  |terminal file                     |soft link to existing file        |0       |d                   |1                   |0             |0             |
|True  |terminal file                     |soft link to self                 |0       |d                   |d                   |1             |1             |
|True  |terminal file                     |soft link to self                 |0       |d                   |0                   |1             |1             |
|True  |terminal file                     |soft link to self                 |0       |d                   |1                   |1             |1             |
|null  |terminal file                     |soft link to nonexistent file     |0       |d                   |d                   |0             |1             |
|null  |terminal file                     |soft link to nonexistent file     |0       |d                   |0                   |0             |1             |
|null  |terminal file                     |soft link to nonexistent file     |0       |d                   |1                   |0             |1             |
|null  |terminal file                     |soft link to self                 |0       |d                   |d                   |1             |0             |
|null  |terminal file                     |soft link to self                 |0       |d                   |0                   |1             |0             |
|null  |terminal file                     |soft link to self                 |0       |d                   |1                   |1             |0             |

Для більшої зрозумілості всі випадки розділено на дві групи. Спочатку лише `src` є софт лінком, а `dst` термінальний файл або не існує (розгляд опції `resolvingDstSoftLink` немає сенсу). Потім `src` є термінальним файлом (розгляд опції `resolvingSrcSoftLink` немає сенсу), а `dst` софт лінком.