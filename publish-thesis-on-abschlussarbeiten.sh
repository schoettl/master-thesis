#!/bin/bash
# Copy, commit, and push thesis in the Abschlussarbeiten repo

declare targetDir=../../Abschlussarbeiten/Jakob_Schoettl

cp thesis.pdf "$targetDir" && \
cd "$targetDir" && \
git add -u . && \
git commit -m 'Update thesis' && \
git push
