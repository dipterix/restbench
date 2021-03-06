% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/option.R
\name{restbatch-option}
\alias{restbatch-option}
\alias{restbatch_setopt}
\alias{restbatch_resetopt}
\alias{restbatch_getopt}
\alias{restbatch_confpath}
\title{Set/Get 'restbatch' option}
\usage{
restbatch_setopt(key, value, .save = TRUE)

restbatch_resetopt(all = FALSE)

restbatch_getopt(key, default = NA, temp = TRUE)

restbatch_confpath(cfile = "settings.yaml")
}
\arguments{
\item{key}{character, option name}

\item{value}{character or logical of length 1, option value}

\item{.save}{whether to save to local drive, internally used to temporary
change option. Not recommended to use it directly.}

\item{all}{whether to reset all non-default keys}

\item{default}{is key not found, return default value}

\item{temp}{when saving, whether the key-value pair should be considered
temporary, a temporary settings will be ignored when saving; when getting
options, setting \code{temp} to false will reveal the actual settings.}

\item{cfile}{file name in configuration path}
}
\value{
\code{restbatch_setopt} returns modified \code{value};
\code{restbatch_resetopt} returns current settings as a list;
\code{restbatch_confpath} returns absolute path for the settings file;
\code{restbatch_getopt} returns the settings value to the given key, or
\code{default} if not found.
}
\description{
Persist settings on local configuration file
}
\details{
\code{restbatch_setopt} stores key-value pair in local path.
The values are persistent and shared across multiple sessions.
There are some read-only keys such as \code{"session_string"}. Trying to
set those keys will result in error.

\code{restbatch_getopt} returns value corresponding to the keys. If key is
missing, the whole option will be returned.

If set \code{all=TRUE}, \code{restbatch_resetopt} resets all keys including
non-standard ones. However \code{"session_string"} will never reset.
}
\seealso{
\code{R_user_dir}
}
