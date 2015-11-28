#!/bin/bash
npm install
DEBUG=*,-socket.io*,-engine*,-send node app
