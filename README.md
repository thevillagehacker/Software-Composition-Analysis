# Software-Composition-Analysis
SCA setup and scanning script using OWASP Dependency Checker, NPM Audit and Snyk.

# Usage

```sh
chmod +x sca_scan.sh
```
# Run

```console
naveenj@HACKERSPACE:[00:00]~$ ./sca_sca.sh
--------------------------------------
Select an option:
1. OWASP Dependency Check Setup
2. OWASP Dependency Check
3. NPM Audit
4. Snyk Run
5. Exit
--------------------------------------
```

* Choose 1 to setup the tool OWASP dependency checker
* Choose 2 to run the OWASP dependency checker tool
* Choose 3 to run NOM audit tool
* Choose 4 to run snyk scan

> To use other options please run the `/SCA/dependency-check/bin/dependency-check.sh` script manually.
> Same applies to npm audit and snyk test.
