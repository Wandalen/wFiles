# Тонкий інтерфейс

Це абстрактиний інтерфейс (back-end), який містить мінімальний набір методів та полів, реалізація яких є специфічною для
кожної файлової системи

Реалізовуючи новий файл-провайдер для роботи із файловою системою, необхідно успадкувати клас `Partial` та написати
специфічну для неї реалізацію всіх рутин із постфіксом `Act`. Одними із таких рутин є: `fileReadAct`, `dirMakeAct`,
`hardLinkAct` та інші. Зробивши це ми автоматично використовуватимемо уже готові алгоритми для роботи з файлами.

# Товстий інтерфейс

Це абстрактиний інтерфейс (front-end), набір методів, полів та алгоритмів, що реалізовані над [тонким інтерфейсом](#тонкий-інтерфейс).

# Файл провайдер

Це реалізація (стратегія) тонкого інтерфейсу (всіх рутин із постфіксом `Act`).

Різні файлові системи вимагають специфічної реалізації рутин для роботи з ними. Таким чином, для кожної файлової системи
існує своя, чимось відмінна від інших, реалізація тонкого інтерфейсу. ...

# Файлова система

Це частина операційної системи, яка контролює спосіб зберігання та отримання даних.

# Файлова система операційної системи

Це посіб організації даних, який використовується операційною системою для збереження інформації у вигляді файлів на носіях інформації.

# Файловий запис

# Фабрика файлових записів

# Файловий фільтр

# Метаданні файла

Це дані, що описують файл.

Файл може мати набір атрибутів (характеристик), які дозволяють файловій системі та іншим API правильно його ідентифікувати і виконувати операції над ним відповідно до метаданих.  

[Повернутись до змісту](../README.md#концепції)

<!-- 
концепції
- Тонкий інтерфейс ( backend ) - набір методів та полів.. згадати про префікс Act
- Товстий інтерфейс ( frontend ) - набір методів та полів.. згадати про префікс Act. Згадати про міксіни FilesFind та Secondary.
- Файл провайдер - стратегія... Згадати що ( частоко ) реалізує тонкий інтерфейс та має свій екземпляр обєкта path для обробки шляхів.
- Файлова система - система, яка... Згадати про клас FileSystem...
- Файлова система операційної системи - ... згадати що реалізована через провайдер HardDrive
- Файловий запис - ...
- Фабрика файлових записів - ... Згадати про клас RecordFactory
- Файловий фільтр - ...
- Метаданні файла - метадані... згадати про клас FileStat
- діаграми

туторіли
різниця між тонким та товстим інтерфейсами, для прикладу розглянути fileWrite fileWriteAct рутини
-->