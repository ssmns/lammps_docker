FROM nvidia/cuda:10.2-devel-ubuntu18.04

LABEL maintainer="ssmns ssmns@outlook.com"
LABEL version="1.0-beta"
LABEL description="This is custom Docker Image for lammps-gpu package."

RUN cp /etc/resolv.conf.override /etc/resolv.conf && \
    cat /etc/resolv.conf &&\
    apt-get update && apt-get install -y --no-install-recommends git make \
    wget libfftw3-dev mpich gfortran build-essential unzip libmpich-dev 
RUN apt-get install --no-install-recommends --no-install-suggests -y curl ca-certificates 

# download and extract
RUN cd /srv  && wget --no-check-certificate https://github.com/lammps/lammps/archive/master.zip
RUN cd /srv && unzip master.zip 

RUN cd /srv/lammps-master/lib/gpu && \
	export PATH=$PATH:/usr/bin && \ 
	make -f Makefile.linux.mixed CUDA_HOME=/usr/local/cuda CUDA_ARCH=-arch=sm_60

RUN cd /srv/lammps-master/src &&\
	make yes-RIGID && \
	make yes-USER-MOLFILE && \
	make yes-BODY && \
	make yes-CLASS2 && \
	make yes-COLLOID && \
	make yes-COMPRESS && \
	make yes-CORESHELL && \
	make yes-DIPOLE  && \
	make yes-MANYBODY && \
	make yes-PERI && \
	make yes-RIGID && \
	make yes-SHOCK && \
	make yes-KSPACE && \
	make yes-MOLECULE && \
	make yes-gpu
	#make yes-reax

RUN cd /srv/lammps-master/src
RUN cd /srv/lammps-master/src &&  make -j 4 mpi && \
    cp /srv/lammps-master/src /bin/lmp_gpu


RUN mkdir /srv/input && mkdir /srv/scratch 
ENV PATH /usr/lib64/mpich/bin:${PATH}
