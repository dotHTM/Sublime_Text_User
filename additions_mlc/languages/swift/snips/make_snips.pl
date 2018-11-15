#!/usr/bin/perl
# make_snips.pl
#   Description

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Template::Liquid;

sub liquid_parse_template {
    my (@args) = @_;
    return Template::Liquid->parse(@args);
}    ##    liquid_parse_template

sub render {
    my (%args) = @_;
    my $template = liquid_parse_template( $args{template} );
    return $template->render(%args);
}    ##    parse_render_template

sub write_to_files {
    my ( $filename, $buffer ) = @_;

    sub write_to_one_file {
        my ( $filename, $buffer ) = @_;
        open( my $FILE_HANDLE, ">", $filename )
            or croak "Cannot open $filename : $!\n";
        print $FILE_HANDLE $buffer or croak "Cannot write $filename : $!\n";
        return 1;    ## success
    }    ##    write_to_one_file
    if ( ref($filename) =~ m/^ARRAY.*/ ) {
        foreach my $file_path ( @{$filename} ) {
            write_to_one_file( $file_path, $buffer );
        }
    }
    else {
        write_to_one_file( $filename, $buffer );
    }
    return 1;    ## success
}    ##    write_to_files

my $snip_template = <<EOL
<snippet>
  <content><![CDATA[
{{ body }}]]></content>
  <tabTrigger>{{ trigger }}</tabTrigger>
  <description>{{ desc }}</description>
  <scope>source.swift</scope>
</snippet>
EOL
    ;

my $bracketed = <<EOL
{{object}} \${100:{{name}}} {
    \${900:// body ...}
} // \${100}
EOL
    ;

my $type_definition = <<EOL
{{object}} \${100:{{name}}}{% if explicitType %}\${200/^.+\$/ : /}\${200:{{explicitType}}}{% endif %} = \${900:{{value}}}
EOL
    ;

my $function_template = <<EOL
{% if object %}{{object}} {% endif %}{{ name }}(\${800:{{inputs}}}){% if returnType %}\${850/^.+\$/->/}\${850:{{returnType}}}{% endif %}{
    \${900:{{body}}}{% if returnType %}\${850/^.+\$/
    return \\/\\/type.../}{% endif %}
} // {{ name }}
EOL
    ;

# assignment
foreach my $someObject ( "let", "var" ) {
    write_to_files(
        ["$someObject.sublime-snippet"],
        render(
            template => $snip_template,
            body     => render(
                template     => $type_definition,
                object       => $someObject,
                name         => "variableName",
                explicitType => "DefaultType",
                value        => "//some value...",
            ),
            trigger => $someObject,
            desc    => $someObject,
        )
    );
}

foreach my $someObject ( "typealias", ) {
    write_to_files(
        ["$someObject.sublime-snippet"],
        render(
            template => $snip_template,
            body     => render(
                template => $type_definition,
                object   => $someObject,
                name     => "TypeName",
                value    => "OriginType",

            ),
            trigger => $someObject,
            desc    => $someObject,
        )
    );
}

# Bracketed objects
foreach my $someObject ( "struct", "class", "enum" ) {
    write_to_files(
        ["$someObject.sublime-snippet"],
        render(
            template => $snip_template,
            body     => render(
                template => $bracketed,
                object   => $someObject,
                name     => "TypeName",

            ),
            trigger => $someObject,
            desc    => $someObject,
        )
    );
}


write_to_files(
    ["func.sublime-snippet"],
    render(
        template => $snip_template,
        body     => render(
            template => $function_template,
            object   => 'func',
            name => '${100:functionName}',
            body => "//body...",
            inputs => "_ someInput : Type",
            returnType => "ReturnType",
        ),
        trigger => 'func',
        desc    => 'func',
    )
);



write_to_files(
    ["switch.sublime-snippet"],
    render(
        template => $snip_template,
        body     => render(
            template => $function_template,
            # object   => $someObject,
            name => "switch",
            body => "case .scenario:
        //body...
    case .scenario:
        //body...
    default:
        //body...",
            inputs => "someInput",

        ),
        trigger => 'switch',
        desc    => 'switch',
    )
);

write_to_files(
    ["init.sublime-snippet"],
    render(
        template => $snip_template,
        body     => render(
            template => $function_template,
            # object   => $someObject,
            name => "init",
            body => "//body...",
            inputs => "_ someInput : Type",
        ),
        trigger => 'init',
        desc    => 'init',
    )
);
