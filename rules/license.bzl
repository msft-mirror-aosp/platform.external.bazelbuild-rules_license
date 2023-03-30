# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Rules for declaring the licenses used by a package."""

load(
    "@rules_license//rules:providers.bzl",
    "LicenseInfo",
    "LicenseKindInfo",
)

# Debugging verbosity
_VERBOSITY = 0

def _debug(loglevel, msg):
    if _VERBOSITY > loglevel:
        print(msg)  # buildifier: disable=print

#
# license()
#

def _license_impl(ctx):
    provider = LicenseInfo(
        license_kinds = tuple([k[LicenseKindInfo] for k in ctx.attr.license_kinds]),
        copyright_notice = ctx.attr.copyright_notice,
        package_name = ctx.attr.package_name,
        package_url = ctx.attr.package_url,
        package_version = ctx.attr.package_version,
        license_text = ctx.file.license_text,
        rule = ctx.label,
    )
    _debug(0, provider)
    return [provider]

_license = rule(
    implementation = _license_impl,
    attrs = {
        "copyright_notice": attr.string(
            doc = "Copyright notice.",
        ),
        "license_kinds": attr.label_list(
            mandatory = True,
            doc = "License kind(s) of this license. If multiple license kinds are" +
                  " listed in the LICENSE file, and they all apply, then all" +
                  " should be listed here. If the user can choose a single one" +
                  " of many, then only list one here.",
            providers = [LicenseKindInfo],
            cfg = "exec",
        ),
        "license_text": attr.label(
            allow_single_file = True,
            default = "LICENSE",
            doc = "The license file.",
        ),
        "package_name": attr.string(
            doc = "A human readable name identifying this package." +
                  " This may be used to produce an index of OSS packages used by" +
                  " an applicatation.",
        ),
        "package_url": attr.string(
            doc = "The URL this instance of the package was download from." +
                  " This may be used to produce an index of OSS packages used by" +
                  " an applicatation.",
        ),
        "package_version": attr.string(
            doc = "A human readable version string identifying this package." +
                  " This may be used to produce an index of OSS packages used" +
                  " by an applicatation.  It should be a value that" +
                  " increases over time, rather than a commit hash."
        ),
    },
)

# buildifier: disable=function-docstring-args
def license(name,
            copyright_notice = None,
            license_kinds = None,
            license_text = None,
            package_name = None,
            package_url = None,
            package_version = None,
            tags = None,
            **kwargs):
    """Wrapper for license rule.

    Args:
      name: str target name.
      license_kinds: list(label) list of license_kind targets.
      license_kind: label a single license_kind. Only one of license_kind or
                    license_kinds may be specified
      copyright_notice: str Copyright notice associated with this package.
      package_name: str A human readable name identifying this package. This
                    may be used to produce an index of OSS packages used by
                    an applicatation.
      package_url: The URL this instance was downloaded from.
      package_version: The version number of this package. This should be a
                       value that increases over time, rather than a commit
                       hash.
      kwargs: Other things may be specified, but they are explicitly ignored.
    """
    single_kind = kwargs.pop("license_kind", default = None)
    if single_kind:
        if license_kinds:
            fail("Can not use both license_kind and license_kinds")
        license_kinds = [single_kind]
    tags = tags or []
    _license(
        name = name,
        license_kinds = license_kinds,
        license_text = license_text or "LICENSE",
        copyright_notice = copyright_notice,
        package_name = package_name,
        package_url = package_url,
        package_version = package_version,
        applicable_licenses = [],
        tags = tags,
        visibility = ["//visibility:public"],
    )
