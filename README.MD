Install pocketsphinx
====================

* `mkrdir sphinxtmp`
* `cd spnixtmp`
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
* `cp sphinxbase/bin /usr/local/sphinxbase`
* `cp pocketsphinx/bin /usr/local/pocketsphinx`