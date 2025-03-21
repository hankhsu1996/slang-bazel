"""Bazel rule for generating version information files from templates."""

def _generate_version_impl(ctx):
    """Implements version_info rule by substituting version data into a template file.

    Takes version information (major, minor, patch, hash) and substitutes it into
    a template file to create a source file with version details.
    """
    # Read version information
    version_major = ctx.attr.version_major
    version_minor = ctx.attr.version_minor
    version_patch = ctx.attr.version_patch
    version_hash = ctx.attr.version_hash

    # Determine inputs
    inputs = [ctx.file.src]
    if hasattr(ctx.attr, "version_file") and ctx.attr.version_file:
        inputs.append(ctx.file.version_file)

    # Create substitutions
    substitutions = {
        "@SLANG_VERSION_MAJOR@": version_major,
        "@SLANG_VERSION_MINOR@": version_minor,
        "@SLANG_VERSION_PATCH@": version_patch,
        "@SLANG_VERSION_HASH@": version_hash,
    }

    # Expand template
    ctx.actions.expand_template(
        template = ctx.file.src,
        output = ctx.outputs.out,
        substitutions = substitutions,
    )

# Rule definition
version_info = rule(
    implementation = _generate_version_impl,
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "Template source file with version placeholders"
        ),
        "version_major": attr.string(
            mandatory = True,
            doc = "Major version number"
        ),
        "version_minor": attr.string(
            mandatory = True,
            doc = "Minor version number"
        ),
        "version_patch": attr.string(
            mandatory = True,
            doc = "Patch version number"
        ),
        "version_hash": attr.string(
            mandatory = True,
            doc = "Git commit hash"
        ),
        "version_file": attr.label(
            allow_single_file = True,
            doc = "Version file generated by git_version rule",
        ),
        "out": attr.output(
            mandatory = True,
            doc = "Output file with version information"
        ),
    },
    doc = "Generates a source file with version information from a template",
)

# Module extension (makes the version_info rule available)
def _version_info_extension_impl():
    pass

version_info_extension = module_extension(
    implementation = _version_info_extension_impl,
)
