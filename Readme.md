# Bonus task
В этом задании вам предстоит поработать с `Concurrency` в `Ruby`.

Задание задаёт конкретную планку по времени, в которую вам нужно уложиться.
В попытках добраться до заданной планки вам придётся разобраться c `Concurrency`.

## Подготовка

- install ruby 2.6.1
- bundle install

## Сервер
В комплект задания входит сервер, написанный на `Falcon`.

Его надо запускать командой `falcon serve -c config.ru --threaded`
Именно в режиме `threaded`.

Сервер предоставляет три эндпоинта: `a`, `b`, `c`.

- `a` отвечает за `1 секунду`
- `b` отвечает за `2 секунды`
- `c` отвечает за `3 секунды`

### Защита от перегрева
Эндпоинты можно вызывать несколько раз одновременно, но в них есть "защита от перегрева".

Если эндпоинт вызывается слишком интенсивно, то запрос, вызвавший перегрев, засыпает на длительное время, чтобы дать серверу охладится. После завершения ожидания клиент получает корректный ответ.

Ограничения на перегрев такие:

- `a` - одновременно может выполняться `3 экземпляра`
- `b` - одновременно может выполняться `2 экземпляра`
- `c` - одновременно может выполняться `1 экземпляр`

## Клиент
В комплект задания входит и клиент, который корректно решает поставленную задачу.
Он делает несколько запросов к серверу, как-то их комбинирует и выводит результат.

## Задача
Проблема в том, что референсное решение отработывает примерно `19,5 секунд`, а в задании требуется уложиться в `7 секунд`.

## Подсказки
1. Начните с того, чтобы нарисовать схему взаимосвязей из референсного решения, и с её помощью найти схему организации вычислительного процесса, которая сможет уложиться в заданные рамки (с учётом защиты от перегрева).

2. В процессе решения вы скорее всего столкнётесь с ситуацией, что понятно, что нужно сделать, но непонятно как: например, выполнить несколько асинхронных задач параллельно и дождаться завершения всех из них. В таких случаях попытайтесь нагуглить типовые решения подобных задач. В процессе поиска вы сможете найти общие шаблоны решения подобных задач, способы их решения в разных языках и библиотеках. В итоге вы поймёте как это сделать в `Ruby`.

3. Можно использовать стандартную библиотеку (`Threads`, ...), библиотеки `socketry`, `concurrent-ruby`, ну и вообще любые библиотеки, какие вы посчитаете нужным.

4. В референсном решении для запросов к серверу используется `Faraday`, можно использовать другие клиенты на ваш выбор.

## Сдача задания
Результатом является `PR` в этот репозиторий, в котором `client.rb` делает все те же запросы к серверу, получает референсный результат, но выполняется в пределах `7 секунд`.
