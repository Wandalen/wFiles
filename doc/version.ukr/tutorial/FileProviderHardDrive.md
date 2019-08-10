# Файлові операції на фізичних накопичувачах

Як використовувати клас <code>FileProvider</code> для роботи з фізичними накопичувачами.

Модуль `Files` пропонує один загальний інтерфейс для операцій з файлами. Цим інтерфейсом є `FileProvider`. В модулі є кілька реалізацій інтерфейсу `FileProvider` для виконання файлових операцій з різними джерелами / напрямками.

Основні класи, що забезпечують реалізацію інтерфейсу `FileProvider`:

- `HardDrive` - здійснення файлових операцій на постійному накопичувачу під управлінням операційних систем `Windows`, `MacOs`, `Linux`-дистрибутивів.
- `Extract` - для створення віртуальної файлової системи в оперативній пам'яті та здійснення файлових операцій в ній.

Додаткові класи, що розширюють можливості модуля:

- `HTTP` - для виконання файлових операцій на стороні браузера та серевера.
- `NPM` - використання протоколів `NPM` для роботи з пакетами `NodeJS`.
- `Git` - використання протоколів `Git` для роботи з `Git`-репозиторіями.
- `HtmlDocument` - для роботи з сторінками сайтів.

### Запис і видалення файла в файловій системі

<details>
  <summary><u>Структура модуля</u></summary>

```
files
  ├── Create.js
  ├── ReadDelete.js
  └── package.json
```

</details>

Для тестування можливостей інтерфейсу `FileProvider` створіть приведену конфігурацію файлів.

В прикладах використовується модуль `Files`. Тому, скопіюйте приведений нижче код в файл `package.json`.

<details>
    <summary><u>Код файла <code>package.json</code></u></summary>

```json    
{
  "dependencies": {
    "wFiles": ""
  }
}
```

</details>

Для встановлення залежностей скористуйтесь командою `npm install`. Після встановлення залежностей модуль готовий до роботи.

<details>
    <summary><u>Код файла <code>Create.js</code></u></summary>

```js    
require( 'wFiles' );
var _ = wTools;

// provider

var fileProvider = _.FileProvider.HardDrive();

// path

var pathFile = _.path.join( _.path.current(), './dir/File.txt' );

// create file

var record = fileProvider.fileWrite(  pathFile, 'Hello, world' );
```

</details>

Внесіть в файл `Create.js` відповідний код.

В коді файла `Create.js`, змінній `fileProvider` присвоєно провайдер `HardDrive`. Це свідчить про те, що модуль буде взаємодіяти з постійним накопичувачем в оточенні вашої операційної системи.

Для того, щоб створити файл, провайдер `fileProvider` використовує рутину `fileWrite`. В рутину `fileWrite` передано шлях до файла `pathFile` та дані, котрі будуть записані в нього. В даному випадку, це рядок `Hello, world`.

Виконайте запуск файла командою `node Create.js`.

Після здійснення операції перевірте зміни в директорії з модулем. Для цього скористайтесь командами `ls -l` i `ls -l ./dir`

<details>
    <summary><u>Вивід команд <code>ls -l</code> i <code>ls -l ./dir</code></u></summary>

```   
$ ls -l
total 44
-rw-r--r--  1 user user   242 Jul 29 14:18 Create.js
drwxr-xr-x  2 user user  4096 Jul 29 14:19 dir
drwxr-xr-x 71 user user  4096 Jul 29 12:51 node_modules
-rw-r--r--  1 user user    45 Jul 29 12:51 package.json
-rw-r--r--  1 user user 21844 Jul 29 12:51 package-lock.json
-rw-r--r--  1 user user   289 Jul 29 14:19 ReadDelete.js
```

```   
$ ls -l ./dir
total 4
-rw-r--r-- 1 user user 8 Jul 29 14:53 File.txt
```

</details>

Як видно з виводу, в директорії `files` з'явилась директорія `dir` з файлом `File.txt`.

<details>
  <summary><u>Структура модуля після запуску файла <code>Create.js</code></u></summary>

```
fileProvider
      ├── dir
      |    └── File.js
      ├── node_modules  
      ├── Create.js
      ├── ReadDelete.js
      ├── package-lock.json
      └── package.json
```

</details>

Приведений вивід консолі відповідає структурі файлів приведеній вище.

Модуль `Files` i клас `FileProvider` забезпечують виконання всіх доступних файлових операцій в визначеній файловій системі. Наприклад, можна виконати читання файла і його видалення.

<details>
    <summary><u>Код файла <code>ReadDelete.js</code></u></summary>

```js    
require( 'wFiles' );
var _ = wTools;

// provider

fileProvider = _.FileProvider.HardDrive();

// path

var pathFile = _.path.join( __dirname, './dir/File.txt' );

// read file

var read = fileProvider.fileRead( pathFile );
console.log( read );

// delete file

fileProvider.fileDelete( pathFile );
```

</details>

В файл `ReadDelete.js` помістіть код, що привдено вище.

Для читання і видалення файла використовуються рутини `fileRead` i `fileDelete`.

<details>
    <summary><u>Вивід команд <code>ls -l</code> i <code>ls -l ./dir</code></u></summary>

```   
$node ReadDelete.js
Hello, world
```

</details>

Запустіть файл командою `node ReadDelete.js`. Порівняйте вивід з приведеним.

Для перевірки вмісту директорії `dir` скористуйтесь командою `ls -l ./dir`

<details>
    <summary><u>Вивід команд <code>ls -l</code> i <code>ls -l ./dir</code></u></summary>

```   
$ ls -l ./dir
total 0
```

</details>

Провайдер прочитав файл та після цього видалив - директорія `dir` порожня.

Можливості `FileProvider` на цьому не вичерпуються. Вони будуть частково розкриті в туторіалах про [віртуальну файлову систему](FileProviderExtract.md), фабрику файлів, пошук файлів та інших. Повну інформацію можна отримати в документації та за списком рутин.

### Підсумок

- Модуль `Files` надає розробнику єдиний інтерфейс для роботи з різними файловими системами.
- Модуль `Files` кросплатформений, тому розробнику не потрібно турбуватись про переносимість коду.
- Для виконання файлових операцій використовується єдиний інтерфейс у вигляді класу `FileProvider`.
- Реалізація `FileProvider` дозволяє працювати з фізичними накопичувачами, віртуальною файловою системою в оперативній пам'яті, а також з віддаленими серверами.
- Клас `HardDrive` дозволяє модулю працювати з фізичними накопичувачами.

[Повернутись до змісту](../README.md#Туторіали)
