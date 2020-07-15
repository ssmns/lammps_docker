FROM ubuntu:18.04

LABEL maintainer="ssmns ssmns@outlook.com"
LABEL version="1.0-beta"
LABEL description="This is custom Docker Image for \
lammps-gpu package."


# RUN apt-get update && apt-get install -y --no-install-recommends \
#     gnupg2 curl ca-certificates && \
#     curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
#     echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
#     apt-get purge --autoremove -y curl && \
#     rm -rf /var/lib/apt/lists/*

# # For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     cuda-cudart-11-0=11.0.171-1 \
#     cuda-compat-11-0 \
#     && ln -s cuda-11.0 /usr/local/cuda && \
#     rm -rf /var/lib/apt/lists/*

# # Required for nvidia-docker v1
# RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
#     echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

# ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
# ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

# # nvidia-container-runtime
# ENV NVIDIA_VISIBLE_DEVICES all
# ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
# #ENV NVIDIA_REQUIRE_CUDA "cuda>=11.0 brand=tesla,driver>=418,driver<419 brand=tesla,driver>=440,driver<441"



# Install Lammps

RUN apt-get update && apt-get  install -y --no-install-recommends \
	git make wget libfftw3-dev \
    mpich gfortran build-essential

RUN rm -rf /var/lib/apt/lists/*

RUN git clone git://git.lammps.org/lammps-ro.git /srv/lammps &&\ 
    cd /srv/lammps && \
    git checkout r15407 && \
    cd src && \
    mkdir -p MAKE/MINE
    
# RUN cd /srv/lammps/lib/gpu && \
#     export PATH=$PATH:/usr/lib64/mpich/bin && \
#     make -f Makefile.linux.mixed CUDA_HOME=/usr/local/cuda CUDA_ARCH=-arch=sm_60

RUN	cd /srv/lammps/lib/reax && \ 
    make -f Makefile.gfortran && \
    cd ../../src &&\
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
	#make yes-gpu && \
	make yes-reax
    # python Make.py -m none -cc g++ -mpi mpich -fft fftw3 -a file && \
    # python Make.py -m auto -p molecule rigid gpu
    
RUN cd /srv/lammps/src && \
    make -j 4 auto MPI_INC="-DMPICH_SKIP_MPICXX -I/usr/include/mpich-x86_64" MPI_LIB="-Wl,-rpath,/usr/lib64/mpich/lib -L/usr/lib64/mpich/lib -lmpl -lmpich" FFT_LIB="-lfftw3" && \
    cp lmp_auto /bin/lmp_gpu
    
RUN mkdir /srv/input && mkdir /srv/scratch

ENV PATH /usr/lib64/mpich/bin:${PATH}
    
