#!/bin/sh

if [ -z "{$LUAROCKS_FILE}" ]; then
    sudo luarocks make ${LUAROCKS_FILE}
fi

if [ ! -z "{$DEP_INSTALL}" ]; then
    for i in $(echo ${DEP_INSTALL} | sed "s/,/ /g")
    do
        # call your procedure/other scripts here below
        sudo luarocks install $i
    done
fi

if [ ! -z "{$LUA_LIBRARIES}" ]; then
    cp -r /mocka_space/${LUA_LIBRARIES}* /usr/local/share/lua/5.1/
fi

if [ ! -z run_tests.lua ]; then

    lua -lluacov run_tests.lua \
        && luacov \
        && luacov-cobertura -o coverage_report.xml
fi

echo " Running luacheck for ${LUA_LIBRARIES} "
luacheck "${LUA_LIBRARIES}" --globals=ngx --no-self

echo " Running ldoc for ${LUA_LIBRARIES} "

if [ -d "docs/style" ]; then
    ldoc -B "${LUA_LIBRARIES}" -d "docs" -s "docs/style" -a
else
    ldoc -B "${LUA_LIBRARIES}" -d "docs" -a
fi
