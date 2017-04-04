TOC=".././gh-md-toc https://github.com/DavidAce/Notebooks/blob/master/DMRG/MPS.md"
#TOC=".././gh-md-toc MPS.md"
START="[comment]: <> (startTOC)"
END="[comment]: <> (startTOC)"

awk -i inplace -v toc="$TOC" -v start="$START" -v end="$END" '
    BEGIN     {p=0}
    /start/   {print; system(toc) ;p=0}
    /end/     {p=1}
    p' MPS.md 


