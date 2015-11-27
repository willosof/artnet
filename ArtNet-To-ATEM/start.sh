#!/bin/bash
npm install
DEBUG=*,-engine*,-send node app
