import logging
import glob
import os
import subprocess

xslname = 'spase2jpcoar.xsl'

if __name__ == '__main__':
    cwd = os.getcwd()

    xsl_original = os.path.join(
        os.path.dirname(__file__),
        xslname)
    xsl = os.path.join(cwd, xslname)
    if not os.path.exists(xsl):
        os.symlink(xsl_original, xsl)

    targets = glob.glob("DisplayData/**/*.xml", recursive=True) + \
        glob.glob("NumericalData/**/*.xml", recursive=True)

    for target in targets:
        cmd = f'xsltproc {xsl} {target}'
        out_xml = os.path.join('jpcoar', target)
        os.makedirs(os.path.dirname(out_xml), 0o755, exist_ok=True)
        with open(out_xml, mode="w") as f:
            proc = subprocess.Popen(
                cmd,
                stdout=f,
                stderr=subprocess.PIPE,
                cwd=cwd,
                shell=True)
            errmsg = proc.stderr.read()
            if len(errmsg) > 0:
                print(f"In '{target}'")
                for msg in errmsg.decode('utf-8').split("\n"):
                    print(f"\t{msg}")

    if xsl != xsl_original:
        os.remove(xsl)
