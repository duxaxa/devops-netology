####1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`  
####Ответ:  
полный хеш коммита `aefead2207ef7e2aa5dc81a34aedf0cad4c32545`  
комментарий коммита: `Update CHANGELOG.md`  
Результат определен с помощью команды:  
`git show aefea`:  

####2. Какому тегу соответствует коммит `85024d3`?  
####Ответ:  
коммит `85024d3` соответствует тегу `v0.12.23`  
Результат определен с помощью команды:  
`git show 85024d3`:  

####3. Сколько родителей у коммита `b8d720`? Напишите их хеши.  
####Ответ:  
Коммит `b8d720` образован в результате слиния (мержа) двух родительских коммитов
с хэшами `56cd7859e` и `56cd7859e` (полные хеши:
`56cd7859e05c36c06b56d013b55a252d0bb7e158` и `56cd7859e05c36c06b56d013b55a252d0bb7e158`)  
Результат определен с помощью команд:   
`git show 85024d3`  
`git show 56cd7859e 9ea88f22f`

####4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами `v0.12.23` и `v0.12.24`.  
####Ответ:  
Коммиты, их хеши и комментарии к ним, сделанные между тегами `v0.12.23` и `v0.12.24`:  

|хеш коммита|комментарий к коммиту|
|:----|:-----|
|33ff1c03bb960b332be3af2e333462dde88b279e|v0.12.24|
|b14b74c4939dcab573326f4e3ee2a62e23e12f89|[Website] vmc provider links|
|3f235065b9347a758efadc92295b540ee0a5e26e|Update CHANGELOG.md|
|6ae64e247b332925b872447e9ce869657281c2bf|registry: Fix panic when server is unreachable|
|5c619ca1baf2e21a155fcdb4c264cc9e24a2a353|website: Remove links to the getting started guide's old location|
|06275647e2b53d97d4f0a19a0fec11f6d69820b5|Update CHANGELOG.md|
|d5f9411f5108260320064349b757f55c09bc4b80|command: Fix bug when using terraform login on Windows|
|4b6d06cc5dcb78af637bbb19c198faff37a066ed|Update CHANGELOG.md|
|dd01a35078f040ca984cdd349f18d0b67e486c35|Update CHANGELOG.md|
|225466bc3e5f35baa5d07197bbc079345b77525e|Cleanup after v0.12.23 release|
Результат определен с помощью команды:  
`git log v0.12.23..v0.12.24 --pretty=oneline`

####5. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит так `func providerSource(...)` (вместо троеточего перечислены аргументы).  
####Ответ:  
Первоначально функция `func providerSource` была создана в коммите `8c928e83589d90a031f811fae52a81be7153e82f`, ее реализация выглядела так:  
```
func providerSource(services *disco.Disco) getproviders.Source {
 ...
}
```
Затем функция `func providerSource` была изменена в коммите `5af1e6234ab6da412fb8637393c5a17a1b293663`, ее реализация была изменена:  
```
func providerSource(configs []*cliconfig.ProviderInstallation, services *disco.Disco) (getproviders.Source, tfdiags.Diagnostics) {
 ...
}
```
Результат определен с помощью команд:  
`git grep -p -r "func providerSource"` - получил список файлов, в которых встречается функция. Это файл *provider_source.go*   
Командой `git log -S"func providerSource"` получил все коммиты, в которых есть упоминания подстроки "providerSource"  
Командой `git show 8c928e83589d90a031f811fae52a81be7153e82f` посмотрел состав первого по хронологии коммита, в новых строках файла *provider_source.go* встречается реализация функции  
Командой `git show 5af1e6234ab6da412fb8637393c5a17a1b293663` посмотрел второй по хронологии коммит, в измененных строках файла *provider_source.go* видно, что функция была реализована новым способом  

####6. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.
####Ответ:  
Функция `globalPluginDirs` не была изменена ни разу с момента создания, т.е. нельзя сказать, что она была изменена в контексте вопроса:  
Такой вывод сделан на основании следующих фактов:  
Команда `git log -S"globalPluginDirs" --pretty=oneline` вернула 3 коммита.  
Далее командами `git show <хеш коммита>` посмотрел каждый из 3-х коммитов и проанализировал изменения
в коде.  
В коммите `8364383c359a6b738a436d1b7745ccdce178df47`функция создана в первый раз, в 2х последующих
коммитах функция упоминается либо в комментариях к коду, либо в теле других функций, т.е. буквальных изменений
в реализации функции нет с момента ее первоначального создания:  
в коммите `c0b17610965450a89598da491ce9b6b5cbd6393f` функция упоминается в добавленном  к коду комментарии:
```
+               // FIXME: homeDir gets called from globalPluginDirs during init, before
```
в коммите `35a058fb3ddfae9cfee0b3893822c9a95b920f4c` функция упоминается в добавленной к коду реализации
другой функции `credentialsSource()`:
```
+func credentialsSource(config *Config) auth.CredentialsSource {
+               ...
+               available := pluginDiscovery.FindPlugins("credentials", globalPluginDirs())
+               ...
+       }
```  
####7. Кто автор функции `synchronizedWriters`?
####Ответ:  
автор функции `synchronizedWriters` *Martin Atkins <mart@degeneration.co.uk>*, функция добавлена в код
в коммите `5ac311e2a91e381e2f52234668b49ba670aa0fe5`.  
Результат определен с помощью команд:  
`git log -S"synchronizedWriters"`  
`git show 5ac311e2a91e381e2f52234668b49ba670aa0fe5`