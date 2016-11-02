#!/bin/sh
#############################################################################
#  Copyright (C) 2013-2015 Lawrence Livermore National Security, LLC.
#  Produced at Lawrence Livermore National Laboratory (cf, DISCLAIMER).
#  Written by Albert Chu <chu11@llnl.gov>
#  LLNL-CODE-644248
#
#  This file is part of Magpie, scripts for running Hadoop on
#  traditional HPC systems.  For details, see https://github.com/llnl/magpie.
#
#  Magpie is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  Magpie is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Magpie.  If not, see <http://www.gnu.org/licenses/>.
#############################################################################

## srun -N5 --time=30 -J "testflux" --partition=pbatch -n5 --ntasks-per-node=1 --exclusive --no-kill --pty src/cmd/flux start magpie.sbatch-srun-spark-test.sh

# Need to tell Magpie how you are submitting this job
export MAGPIE_SUBMISSION_TYPE="srunfluxwreckrun"

############################################################################
# Magpie Configurations
############################################################################

# Directory your launching scripts/files are stored
#
# Normally an NFS mount, someplace magpie can be reached on all nodes.
export MAGPIE_SCRIPTS_HOME="${HOME}/chaos/git/magpie"

# Path to store data local to each cluster node, typically something
# in /tmp.  This will store local conf files and log files for your
# job.  If local scratch space is not available, consider using the
# MAGPIE_NO_LOCAL_DIR option.  See README for more details.
#
export MAGPIE_LOCAL_DIR="/tmp/${USER}/magpie"

# Magpie job type
#
# "hadoop" - Run a job according to the settings of HADOOP_MODE.
#
# "testall" - Run a job that runs all basic sanity tests for all
#             software that is configured to be setup.  This is a good
#             way to sanity check that everything has been setup
#             correctly and the way you like.
#
#             For Hadoop, testall will run terasort
#
# "script" - Run an arbitraty script, as specified by
#            MAGPIE_SCRIPT_PATH.  This functionally is very similar to
#            setting "script" in HADOOP_MODE or HBASE_MODE or
#            SPARK_MODE.
#
#            It is primarily used if you want to launch without
#            Hadoop/Hbase/Spark and are experimenting with things..
#
# "interactive" - manually interact with job run.  This functionally
#                 is very similar to setting "interactive" in
#                 HADOOP_MODE, HBASE_MODE, SPARK_MODE, etc.  It is
#                 primarily used if you want to launch without
#                 Hadoop/Hbase/Spark/etc. and are experimenting with
#                 things.
#
export MAGPIE_JOB_TYPE="spark"

# Specify script to execute for "script" mode in MAGPIE_JOB_TYPE
#
# export MAGPIE_SCRIPT_PATH="${HOME}/chaos/git/my-job-script"

# Specify arguments for script specified in MAGPIE_SCRIPT_PATH
#
# Note that many Magpie generated environment variables are not
# generated until the job has launched.  You won't be able to use them
# here.
#
# export MAGPIE_SCRIPT_ARGS="" 

# Specify script startup / shutdown time window
#
# Specifies the amount of time to give startup / shutdown activities a
# chance to succeed before Magpie will give up (or in the case of
# shutdown, when the resource manager/scheduler may kill the running
# job).  Defaults to 30 minutes for startup, 30 minutes for shutdown.
#
# The startup time in particular may need to be increased if you have
# a large amount of data.  As an example, HDFS may need to spend a
# significant amount of time determine all of the blocks in HDFS
# before leaving safemode.
#
# The stop time in particular may need to be increased if you have a
# large amount of cleanup to be done.  HDFS will save its NameSpace
# before shutting down.  Hbase will do a compaction before shutting
# down.
#
# The startup & shutdown window must together be smaller than the
# SBATCH_TIMELIMIT specified above.
#
# MAGPIE_STARTUP_TIME and MAGPIE_SHUTDOWN_TIME at minimum must be 5
# minutes.  If MAGPIE_POST_JOB_RUN is specified below,
# MAGPIE_SHUTDOWN_TIME must be at minimum 10 minutes.
#
export MAGPIE_STARTUP_TIME=5
export MAGPIE_SHUTDOWN_TIME=10

# Convenience Scripts
#
# Specify script to be executed to before / after your job.  It is run
# on all nodes.
#
# Typically the pre-job script is used to set something up or get
# debugging info.  It can also be used to determine if system
# conditions meet the expectations of your job.  The primary job
# running script (magpie-run) will not be executed if the
# MAGPIE_PRE_JOB_RUN exits with a non-zero exit code.
#
# The post-job script is typically used for cleaning up something or
# gathering info (such as logs) for post-debugging/analysis.  If it is
# set, MAGPIE_SHUTDOWN_TIME above must be > 5.
#
# See example magpie-example-pre-job-script and
# magpie-example-post-job-script for ideas of what you can do w/ these
# scripts
#
# A number of convenient scripts are available in the
# ${MAGPIE_SCRIPTS_HOME}/scripts directory.
#
# export MAGPIE_PRE_JOB_RUN="${MAGPIE_SCRIPTS_HOME}/scripts/pre-job-run-scripts/my-pre-job-script"
export MAGPIE_POST_JOB_RUN="${MAGPIE_SCRIPTS_HOME}/scripts/post-job-run-scripts/magpie-gather-config-files-and-logs-script.sh"

# Environment Variable Script
#
# When working with Magpie interactively by logging into the master
# node of your job allocation, many environment variables may need to
# be set.  For example, environment variables for config file
# directories (e.g. HADOOP_CONF_DIR, HBASE_CONF_DIR, etc.) and home
# directories (e.g. HADOOP_HOME, HBASE_HOME, etc.) and more general
# environment variables (e.g. JAVA_HOME) may need to be set before you
# begin interacting with your big data setup.
#
# The standard job output from Magpie provides instructions on all the
# environment variables typically needed to interact with your job.
# However, this can be tedious if done by hand.
#
# If the environment variable specified below is set, Magpie will
# create the file and put into it every environment variable that
# would be useful when running your job interactively.  That way, it
# can be sourced easily if you will be running your job interactively.
# It can also be loaded or used by other job scripts.
#
# export MAGPIE_ENVIRONMENT_VARIABLE_SCRIPT="${HOME}/chaos/git/my-job-env"

# Environment Variable Shell Type
#
# Magpie outputs environment variables in help output and
# MAGPIE_ENVIRONMENT_VARIABLE_SCRIPT based on your SHELL environment
# variable.
#
# If you would like to output in a different shell type (perhaps you
# have programmed scripts in a different shell), specify that shell
# here.
#
# export MAGPIE_ENVIRONMENT_VARIABLE_SCRIPT_SHELL="/bin/bash"

# Remote Shell
#
# Magpie requires a passwordless remote shell command to launch
# necessary daemons across your job allocation.  Magpie defaults to
# ssh, but it may be an alternate command in some environments.  An
# alternate ssh-equivalent remote command can be specified by setting
# MAGPIE_REMOTE_CMD below.
#
# If using ssh, Magpie requires keys to be setup ahead of time so it
# can be executed without passwords.
#
# Specify options to the remote shell command if necessary.
#
export MAGPIE_REMOTE_CMD="mrsh"
# export MAGPIE_REMOTE_CMD_OPTS=""

############################################################################
# General Configuration
############################################################################

# Necessary for most projects
export JAVA_HOME="/usr/lib/jvm/jre-1.7.0-oracle.x86_64"

# MAGPIE_PYTHON path used for:
# - Spark PySpark path
export MAGPIE_PYTHON="/usr/bin/python"

############################################################################
# Spark Core Configurations
############################################################################

# Should Spark be run
#
# Specify yes or no.  Defaults to no.
#
export SPARK_SETUP=yes

# Version
#
export SPARK_VERSION="2.0.1-bin-hadoop2.7"

# Path to your Spark build/binaries
#
# This should be accessible on all nodes in your allocation. Typically
# this is in an NFS mount.
#
# Ensure the build matches the Hadoop/HDFS version this will run against.
#
export SPARK_HOME="${HOME}/bigdata/spark-${SPARK_VERSION}"

# Path to store data local to each cluster node, typically something
# in /tmp.  This will store local conf files and log files for your
# job.  If local scratch space is not available, consider using the
# MAGPIE_NO_LOCAL_DIR_DIR option.  See README for more details.
#
export SPARK_LOCAL_DIR="/tmp/${USER}/spark"

# Directory where alternate Spark configuration templates are stored
#
# If you wish to tweak the configuration files used by Magpie, set
# SPARK_CONF_FILES below, copy configuration templates from
# $MAGPIE_SCRIPTS_HOME/conf/spark into SPARK_CONF_FILES, and modify as
# you desire.  Magpie will still use configuration files in
# $MAGPIE_SCRIPTS_HOME/conf/spark if of the files it needs are not
# found in SPARK_CONF_FILES.
#
# export SPARK_CONF_FILES="${HOME}/myconf"

# Worker Cores per Node
#
# If not specified, a reasonable estimate will be calculated based on
# number of CPUs on the system.
#
# Be aware of the number of tasks and the amount of memory that may be
# needed by other software.
#
# export SPARK_WORKER_CORES_PER_NODE=8

# Worker Memory
#
# Specified in M.  If not specified, a reasonable estimate will be
# calculated based on total memory available and number of CPUs on the
# system.
#
# Be aware of the number of tasks and the amount of memory that may be
# needed by other software.
#
# export SPARK_WORKER_MEMORY_PER_NODE=16000

# Worker Directory
#
# Directory to run applications in, which will include both logs and
# scratch space for local jars.  If not specified, defaults to
# SPARK_LOCAL_DIR/work.
#
# Generally speaking, this is best if this is a tmp directory such as
# in /tmp
#
# export SPARK_WORKER_DIRECTORY=/tmp/${USER}/spark/work

# SPARK_JOB_MEMORY
#
# Memory for spark jobs.  Defaults to being set equal to
# SPARK_WORKER_MEMORY_PER_NODE, but users may wish to lower it if
# multiple Spark jobs will be submitted at the same time.
#
# In Spark parlance, this will set both the executor and driver memory
# for Spark.
#
# export SPARK_JOB_MEMORY="2048"

# SPARK_DRIVER_MEMORY
#
# Beginning in Spark 1.0, driver memory could be configured separately
# from executor memory.  If SPARK_DRIVER_MEMORY is set below, driver
# memory will be configured differently than the executor memory
# indicated above with SPARK_JOB_MEMORY.
#
# If running Spark < 1.0, this option does nothing.
#
# export SPARK_DRIVER_MEMORY="2048"

# Daemon Heap Max
#
# Heap maximum for Spark daemons, specified in megs.
#
# If not specified, defaults to 1000
#
# May need to be increased if you are scaling large, get OutofMemory
# errors, or perhaps have a lot of cores on a node.
#
# export SPARK_DAEMON_HEAP_MAX=2000

# Environment Extra
#
# Specify extra environment information that should be passed into
# Spark.  This file will simply be appended into the spark-env.sh.
#
# By default, a reasonable estimate for max user processes and open
# file descriptors will be calculated and put into spark-env.sh.
# However, it's always possible they may need to be set
# differently. Everyone's cluster/situation can be slightly different.
#
# See the example example-environment-extra for examples on
# what you can/should do with adding extra environment settings.
#
# export SPARK_ENVIRONMENT_EXTRA_PATH="${HOME}/spark-my-environment"

############################################################################
# Spark Job/Run Configurations
############################################################################

# Set how Spark should run
#
# "sparkpi" - run sparkpi example. Useful for making sure things are
#             setup the way you like.
#
#             There are additional configuration options for this
#             example listed below.
#
# "sparkwordcount" - run wordcount example.  Useful for making sure
#                    things are setup the way you like.
#
#                    See below for additional required configuration
#                    for this example.
#
# "script" - execute a script that lists all of your Spark jobs.  Be
#            sure to set SPARK_SCRIPT_PATH to your script.
#
# "interactive" - manually interact to submit jobs, peruse Spark, etc.
#                 In this mode you'll login to the cluster node that
#                 is your 'master' node and interact with Spark
#                 directly (e.g. bin/spark-shell ...)
#
# "setuponly" - Like 'interactive' but only setup conf files. useful
#               if user wants to setup & teardown daemons themselves.
#
export SPARK_MODE="sparkpi"

# SPARK_DEFAULT_PARALLELISM
#
# Default number of tasks to use across the cluster for distributed
# shuffle operations (groupByKey, reduceByKey, etc) when not set by
# user. If not specified, defaults to # compute nodes (i.e. 1 per node)
#
# This is something you (the user) almost definitely want to set.
#
# export SPARK_DEFAULT_PARALLELISM=8

# SPARK_MEMORY_FRACTION
#
# Fraction of heap space used for execution and storage. The lower
# this is, the more frequently spills and cached data eviction occur.
#
# This configuration only works for Spark versions >= 1.6.0.  See
# SPARK_STORAGE_MEMORY_FRACTION and SPARK_SHUFFLE_MEMORY_FRACTION for
# older versions.
#
# Defaults to 0.75
#
# export SPARK_MEMORY_FRACTION=0.75

# SPARK_MEMORY_STORAGE_FRACTION
#
# Amount of storage memory immune to eviction, expressed as a fraction
# of the size of the region set aside by SPARK_MEMORY_FRACTION.  The
# higher this is, the less working memory may be available to
# executiona nd tasks may spill to disk more often.
#
# This configuration only works for Spark versions >= 1.6.0.  See
# SPARK_STORAGE_MEMORY_FRACTION and SPARK_SHUFFLE_MEMORY_FRACTION for
# older versions.
#
# Defaults to 0.5
#
# export SPARK_MEMORY_STORAGE_FRACTION=0.5

# SPARK_STORAGE_MEMORY_FRACTION
#
# Configure fraction of Java heap to use for Spark's memory cache.
# This should not be larger than the "old" generation of objects in
# the JVM.  This can highly affect performance due to interruption due
# to JVM garbage collection.  If a large amount of time is spent in
# garbage collection, consider shrinking this value, such as to 0.5 or
# 0.4.
#
# This configuration only works for Spark versions < 1.6.0.  Starting
# with 1.6.0, see SPARK_MEMORY_FRACTION and
# SPARK_MEMORY_STORAGE_FRACTION.
#
# Defaults to 0.6
#
# export SPARK_STORAGE_MEMORY_FRACTION=0.6

# SPARK_SHUFFLE_MEMORY_FRACTION
#
# Fraction of Java heap to use for aggregation and cogroups during
# shuffles.  At any given time, the collective size of all in-memory
# maps used for shuffles is bounded by this limit, beyond which the
# contents will begin to spill to disk.  If spills are often, consider
# increasing this value at the expense of storage memory fraction
# (SPARK_STORAGE_MEMORY_FRACTION above).
#
# This configuration only works for Spark versions < 1.6.0.  Starting
# with 1.6.0, see SPARK_MEMORY_FRACTION and
# SPARK_MEMORY_STORAGE_FRACTION.
#
# Defaults to 0.3
#
# export SPARK_SHUFFLE_MEMORY_FRACTION=0.3

# SPARK_DEPLOY_SPREADOUT
#
# Per Spark documentation, "Whether the standalone cluster manager
# should spread applications out across nodes or try to consolidate
# them onto as few nodes as possible. Spreading out is usually better
# for data locality in HDFS, but consolidating is more efficient for
# compute-intensive workloads."
#
# If you are hard coding parallelism in certain parts of your
# application because those individual actions do not scale well, it
# may be beneficial to disable this.
#
# Defaults to true
#
# export SPARK_DEPLOY_SPREADOUT=true

# SPARK_JOB_CLASSPATH
#
# May be necessary to set to get certain code/scripts to work.
#
# e.g. to run a Spark example, you may need to set
#
# export SPARK_JOB_CLASSPATH="examples/target/spark-examples-assembly-0.9.1.jar"
#
# Note that this is primarily for Spark 0.9.1 and earlier versions.
# You likely want to use the --driver-class-path option in
# spark-submit now.
#
# export SPARK_JOB_CLASSPATH=""

# SPARK_JOB_LIBRARY_PATH
#
# May be necessary to set to get certain code/scripts to work.
#
# Note that this is primarily for Spark 0.9.1 and earlier versions.
# You likely want to use the --driver-library-path option in
# spark-submit now.
#
# export SPARK_JOB_LIBRARY_PATH=""

# SPARK_JOB_JAVA_OPTS
#
# May be necessary to set options to set Spark options
#
# e.g. -Dspark.default.parallelism=16
#
# Magpie will set several options on its own, however, these options
# will be appended last, ensuring they override anything that Magpie
# will set by default.
#
# Note that many of the options that were set in SPARK_JAVA_OPTS in
# Spark 0.9.1 and earlier have been deprecated.  You likely want to
# use the --driver-java-options option in spark-submit now.
#
# export SPARK_JOB_JAVA_OPTS=""

# SPARK_LOCAL_SCRATCH_DIR
#
# By default, if Hadoop is setup with a file system, the Spark local
# scratch directory, where scratch data is placed, will automatically
# be calculated and configured.  If Hadoop is not setup, the following
# must be specified.
#
# If you have local SSDs or NVRAM stored on the nodes of your system,
# it may be in your interest to set this to a local drive.  It can
# improve performance of both shuffling and disk based RDD
# persistence.  If you want to specify multiple paths (such as
# multiple drives), make them comma separated
# (e.g. /dir1,/dir2,/dir3).
#
# Note that this field will not work if SPARK_USE_YARN is set to
# 'yes'.  Please set HADOOP_LOCALSTORE to inform Yarn to set a local
# SSD for Yarn to use for local scratch.
#
export SPARK_LOCAL_SCRATCH_DIR="/tmp/${USER}/sparkscratch"

# SPARK_LOCAL_SCRATCH_DIR_CLEAR 
#
# After your job has completed, if SPARK_LOCAL_SCRATCH_DIR_CLEAR is
# set to yes, Magpie will do a rm -rf on all directories in
# SPARK_LOCAL_SCRATCH_DIR.  This is particularly useful if the local
# scratch directory is on local storage and you want to clean up your
# work before the next user uses the node.
#
# export SPARK_LOCAL_SCRATCH_DIR_CLEAR="yes"

# SPARK_USE_YARN
#
# By default, Magpie uses the Spark standalone scheduler.  As
# resources do not need to be competed for in a Magpie environment
# (you the user have all the resources allocated via the
# scheduler/resource manager of your cluster), the Spark scheduler is
# more appropriate for use under Magpie.
#
# However, users who may have scripted/coded against Yarn before may
# find porting into Magpie easier if Yarn was defaulted to instead of
# the standalone scheduler.  If SPARK_USE_YARN is set to 'yes' below,
# the following differences will happen within Magpie.
#
# - The Spark standalone scheduler will not be launched 
# - The default Spark master will be set to 'yarn-client' in all
#   appropriate locations (e.g. spark-defaults.conf)
# - All situations that would otherwise use the standalone scheduler
#   (e.g. SPARK_MODE="sparkpi" or SPARK_MODE="script") will now use
#   Yarn instead.
# 
# Note that SPARK_LOCAL_SCRATCH_DIR above will not work if
# SPARK_USE_YARN is set to 'yes'.  Please set HADOOP_LOCALSTORE to
# inform Yarn to set a local SSD for Yarn to use for local scratch.
#
# Make sure that HADOOP_SETUP_TYPE is set to MR2 so Yarn will be
# launched if you set SPARK_USE_YARN to yes.
#
# Defaults to no.
#
# export SPARK_USE_YARN=yes

# SPARK_YARN_STAGING_DIR
#
# By default, Spark w/ Yarn will use your home directory for staging
# files for a job.  This home directory must be accessible by all
# nodes.
#
# This may pose a problem if you are not using HDFS and your home
# directory is not NFS or network mounted.  Set this value to a
# network location as your staging directory.  Be sure to prefix this
# path the appropriate scheme, such as file://.
# 
# This option is only available beginning in Spark 2.0.
#
# export SPARK_YARN_STAGING_DIR="file:///lustre/${USER}/sparkStaging/"

############################################################################
# Spark SparkPi Configuration
############################################################################

# SparkPi Slices
#
# Number of "slices" to parallelize in Pi estimation.  Generally
# speaking, more should lead to more accurate estimates.
#
# If not specified, equals number of nodes.
#
# export SPARK_SPARKPI_SLICES=4

############################################################################
# Spark SparkWordCount Configuration
############################################################################

# SparkWordCount File
#
# Specify the file to do the word count on.  Specify the scheme, such
# as hdfs:// or file://, appropriately.
#
# export SPARK_SPARKWORDCOUNT_FILE="/mywordcountfile"

# SparkWordCount Copy In File
#
# In some cases, a file must be copied in before it can be used.  Most
# notably, this can be the case if the file is not yet in HDFS.
#
# If specified below, the file will be copied to the location
# specified by SPARK_SPARKWORDCOUNT_FILE before the word count is
# executed.
#
# Specify the scheme appropriately.  At this moment, the schemes of
# file:// and hdfs:// are recognized for this option.
#
# Note that this is not required.  The file could be copied in any
# number of other ways, such as through a previous job or through a
# script specified via MAGPIE_PRE_JOB_RUN.
#
# export SPARK_SPARKWORDCOUNT_COPY_IN_FILE="/mywordcountfile"

############################################################################
# Spark Script Configurations
############################################################################

# Specify script to execute for "script" mode
#
# See examples/spark-example-job-script for example of what to put in
# the script.
#
# export SPARK_SCRIPT_PATH="${HOME}/my-job-script"

# Specify arguments for script specified in SPARK_SCRIPT_PATH
#
# Note that many Magpie generated environment variables, such as
# SPARK_MASTER_NODE, are not generated until the job has launched.
# You won't be able to use them here.
#
# export SPARK_SCRIPT_ARGS="" 

############################################################################
# Run Job
############################################################################

# wreckrun doesn't forward SLURM environment variables, save these off
# via a workaround
  
export MAGPIE_FLUX_JOB_NAME=${SLURM_JOB_NAME}
export MAGPIE_FLUX_JOB_ID=${SLURM_JOB_ID}

# Don't use SLURM_JOB_NODELIST, as thats "cheating", we'll build our
# own nodelist.  Assumes 'hostlist' command available

export MAGPIE_FLUX_JOBLIST=`flux exec hostname | hostlist`

flux wreckrun -N${SLURM_NNODES} $MAGPIE_SCRIPTS_HOME/magpie-check-inputs
if [ $? -ne 0 ]
then
   exit 1
fi
flux wreckrun -N${SLURM_NNODES} $MAGPIE_SCRIPTS_HOME/magpie-setup-core
if [ $? -ne 0 ]
then
   exit 1
fi
flux wreckrun -N${SLURM_NNODES} $MAGPIE_SCRIPTS_HOME/magpie-setup-projects
if [ $? -ne 0 ]
then
    exit 1
fi
flux wreckrun -N${SLURM_NNODES} $MAGPIE_SCRIPTS_HOME/magpie-setup-post
if [ $? -ne 0 ]
then
    exit 1
fi
flux wreckrun -N${SLURM_NNODES} $MAGPIE_SCRIPTS_HOME/magpie-pre-run
if [ $? -ne 0 ]
then
    exit 1
fi
flux wreckrun -N${SLURM_NNODES} $MAGPIE_SCRIPTS_HOME/magpie-run
flux wreckrun -N${SLURM_NNODES} $MAGPIE_SCRIPTS_HOME/magpie-cleanup
flux wreckrun -N${SLURM_NNODES} $MAGPIE_SCRIPTS_HOME/magpie-post-run
