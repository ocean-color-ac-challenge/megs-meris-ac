## MEGS(c) MERIS Level 1 to Level 2 atmospheric correction


### MERIS atmospheric correction effects using MEGS(c)

This tutorial builds upon the ESA ODESA (Optical Data Processor of the European Space Agency) project. More context information is available from the [project web page](http://earth.eo.esa.int/odesa/).

Hereafter, we will guide you to implement a "MERIS Level 1 to Level 2 atmospheric correction using ODESA" application on Terradue's Cloud Platform, a set of Cloud services to develop, test and exploit scalable, distributed earth data processors.

### Getting started

To run this application, you will need a Developer Cloud Sandbox that can be requested from [Terradue's Portal](http://www.terradue.com/partners), provided user registration approval. 

### Installation

You can install the application in two ways, via rpm or via mvn

* Download and install via rpm

Click on the latest release available in the releases page, then copy the file to your sandbox:

```bash
scp megs-meris-ac-0.1-ciop.noarch.rpm <your sandbox ip>:
```
Log on the developer sandbox and run this command in a shell:

```bash
sudo yum -y install megs-meris-ac
```

* install via mvn

Log on the developer sandbox and run these commands in a shell:

```bash
sudo yum -y install megs
git clone git@github.com:ocean-color-ac-challenge/megs-meris-ac.git
cd megs-meris-ac
mvn install
```

This will install the megs-meris-ac application and the megs processor from ESA.

### Submitting the workflow

Run this command in a shell:

```bash
ciop-simwf
```

Or invoke the Web Processing Service via the Sandbox dashboard providing a start/stop date in the format YYYY/MM/DD (e.g. 2012-04-01 and 2012-04-03) and a bounding box (upper left lat/lon, lower right lat/lon).

### Community and Documentation

To learn more and find information go to 

* [Developer Cloud Sandbox](http://docs.terradue.com/developer-sandbox) service 

### Authors (alphabetically)

* Fabio D'Andria

### License

Copyright 2014 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
