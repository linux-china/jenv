#!/bin/bash

./gradlew -Penv=prod

cp -rf build/jenv/* ~/.jenv/
