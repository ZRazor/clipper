Install pocketsphinx
====================

* зайти в папку с проектом
* `mkrdir sphinx`
* `cd sphinx`
* `git clone https://github.com/cmusphinx/pocketsphinx-ios-demo.git`
* `git clone https://github.com/cmusphinx/sphinxbase.git`
* `git clone https://github.com/cmusphinx/pocketsphinx.git`
* проверить есть ли `which autoconf` и `which automake`
* `cd sphinxbase` `./autogen.sh` выполнять make не нужно, мб что нужно будет доставить через brew
* `cd ..`
* `cd pocketsphinx` `./autogen.sh` выполнять make не нужно
* `cd ..`
* `cp pocketsphinx-ios-demo/build_iphone.sh sphinxbase/build_iphone.sh`
* `cp pocketsphinx-ios-demo/build_iphone.sh pocketsphinx/build_iphone.sh`
* `cd sphinxbase` `chmod +x build_iphone.sh` `./build_iphone.sh`
* `cd pocketsphinx` `chmod +x build_iphone.sh` `./build_iphone.sh`
* прописать в настройках проекта Header Search Paths:
```
${PROJECT_DIR}/sphinx/sphinxbase/bin/x86_64/include/sphinxbase
${PROJECT_DIR}/sphinx/sphinxbase/bin/x86_64/include
${PROJECT_DIR}/sphinx/pocketsphinx/bin/x86_64/include/pocketsphinx
${PROJECT_DIR}/sphinx/pocketsphinx/bin/x86_64/include
```
* прописать в Library Search path:
```
${PROJECT_DIR}/sphinx/sphinxbase/bin/x86_64/lib
${PROJECT_DIR}/sphinx/pocketsphinx/bin/x86_64/lib
```
* прописать в Other Linker Flags
```
-lsphinxbase
-lpocketsphinx
```