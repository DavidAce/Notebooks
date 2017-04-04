TOC=".././gh-md-toc https://github.com/DavidAce/Notebooks/blob/master/DMRG/MPS.md"
START="[#startTOC]:"
END="[#endTOC]:"

awk -i inplace -v toc="$TOC" -v start="$START" -v end="$END" '
    BEGIN     {p=0}
    /start/   {print; system(toc) ;p=0}
    /end/     {p=1}
    p' MPS.md 


