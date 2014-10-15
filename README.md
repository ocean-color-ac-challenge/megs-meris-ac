## MERIS atmospheric correction effects using MEGS(c)

This tutorial builds upon the ESA ODESA (Optical Data Processor of the European Space Agency) project. More context information is available from the [project web page](http://earth.eo.esa.int/odesa/).

### Getting started

The Getting started guide to implement a "MERIS Level 1 to Level 2 atmospheric correction using MEGS(c)" application on Terradue's Developer Cloud Sandbox platform, a set of Cloud services to develop, test and exploit scalable, distributed Earth Science processors.

To run this application, you will need a Developer Cloud Sandbox that can be requested from [Terradue's Portal](http://www.terradue.com/partners), provided user registration approval. 

#### Installation

You can install the application in two ways, via mvn or via rpm

* install via mvn

Log on the developer sandbox and run these commands in a shell:

```bash
sudo yum -y install megs
git clone git@github.com:ocean-color-ac-challenge/megs-meris-ac.git
cd megs-meris-ac
mvn install
```

This will install the megs-meris-ac application and the megs processor from ESA.

* Download and install via rpm

Click on the latest release available in the releases page, then copy the file to your sandbox:

```bash
scp megs-meris-ac-0.1-ciop.noarch.rpm <your sandbox ip>:
```
Log on the developer sandbox and run this command in a shell:

```bash
sudo yum -y install megs-meris-ac
```

#### Submitting the workflow

Run this command in a shell:

```bash
ciop-simwf
```

Or invoke the Web Processing Service via the Sandbox dashboard providing a start/stop date in the format YYYY/MM/DD (e.g. 2012-04-01 and 2012-04-03) and a bounding box (upper left lat/lon, lower right lat/lon).

#### Using custom ADF

You can use ODESA to create a new set of ADFs. 

Section 3.4.4 of the ODESA Quick Start Guide (ODESA-ACR-QSG issue 1.2.4 of March 5, 2012) shows how to edit the ADFs:

> New ADFs created and modified by the user are placed in the working directory. 

> The general directory structure is as follows:

> $WORKING_DIRECTORY/auxdatafiles/(processor_type)/(adf_format)/(adf_type)

> For example a new ADF for the atmosphere products using the default name (atmosphere_copy.prd) would be found under:

> $WORKING_DIRECTORY/auxdatafiles/megs/20/atmosphere_copy.prd 

* Provide an compressed archive of the auxdatafiles folder with:

```bash
cd $WORKING_DIRECTORY
tar cvfz auxdatafiles.tgz auxdatafiles
```

> Chech [here](assets/auxdatafiles) the typical content of $WORKING_DIRECTORY/auxdatafiles

* Upload the auxdatafiles.tgz archive to your sandbox with:

```bash
scp auxdatafiles.tgz <sandbox ip>:/tmp
```

* Invoke MEGS application:

  * via the WPS web interface with the parameter: *file:///tmp/auxdatafiles.tgz*
  * edit the application.xml and set the *prdurl* parameter value to *file:///tmp/auxdatafiles.tgz*; do a ciop-simwf

### Community and Documentation

To learn more and find information go to 

* [Developer Cloud Sandbox](http://docs.terradue.com/developer-sandbox) service 

### Authors (alphabetically)

* Fabrice Brito
* Fabio D'Andria

### License

Copyright 2014 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
