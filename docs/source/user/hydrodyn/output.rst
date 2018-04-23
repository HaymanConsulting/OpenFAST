.. hd__output:

Output Files
============

HydroDyn produces three types of output files: an echo file, a summary
file, and a time-series results file. The following sections detail the
purpose and contents of these files.

Echo Files
----------

If you set the ``Echo`` flag to ``TRUE`` in the HydroDyn driver file or the
HydroDyn primary input file, the contents of those files will be echoed
to a file with the naming conventions, ``OutRootName**.ech`` for the
driver input file and ``OutRootName**.HD.ech`` for the HydroDyn primary
input file. ``OutRootName`` is either specified in the HYDRODYN
section of the driver input file when running HydroDyn standalone, or by
the OpenFAST program when running a coupled simulation. The echo files are
helpful for debugging your input files. The contents of an echo file
will be truncated if HydroDyn encounters an error while parsing an input
file. The error usually corresponds to the line after the last
successfully echoed line.

Summary File
------------

HydroDyn generates a summary file with the naming convention,
``OutRootName**.HD.sum`` if the ``HDSum`` parameter is set to ``TRUE``.
``OutRootName`` is either specified in the HYDRODYN
section of the driver input file when running HydroDyn standalone, or by
the OpenFAST program when running a coupled simulation. This file summarizes key
information about the hydrodynamics model, including which features have
been enabled and what outputs have been selected.

Results Files
-------------

In standalone mode, if ``OutSwtch`` in the OUTPUT section of the HydroDyn input file
is set to either 1 or 3the HydroDyn time-series results are written to 
text-based files with the naming convention ``OutRootName**.HD.out``, 
where ``OutRootName`` is specified in the HYDRODYN section of 
the driver input file. If HydroDyn is coupled to OpenFAST, then OpenFAST
will generate a master results file that includes the HydroDyn results if the ``OutSwtch``
option is set to 2 or 3. The results are in table
format, where each column is a data channel (the first column always
being the simulation time), and each row corresponds to a simulation
output time step. The data channels are specified in the OUTPUT CHANNELS section
of the HydroDyn primary input file. The column format of the
HydroDyn-generated files is specified using the ``OutFmt`` parameter of
the HydroDyn primary input file.
