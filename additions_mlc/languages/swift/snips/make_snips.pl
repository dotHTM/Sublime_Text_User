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

sub make_snip {
    my ( $someObject, %args ) = @_;

    write_to_files(
        ["$someObject.sublime-snippet"],
        render(
            template => <<EOL
<snippet>
  <content><![CDATA[
{{ body }}]]></content>
  <tabTrigger>{{ trigger }}</tabTrigger>
  <description>{{ desc }}</description>
  <scope>source.swift</scope>
</snippet>
EOL
            ,
            body    => render(%args),
            trigger => $someObject,
            desc    => $someObject,
        )
    );
}    ##    make_snip

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

my %snippetHash = (
    "init" => {
        template => $function_template,
        name     => "init",
        body     => "//body...",
        inputs   => "_ someInput : Type",
    },
    "switch" => {
        template => $function_template,
        name     => "switch",
        body     => 'case .scenario:
        //body...
    case .scenario:
        //body...
    default:
        //body...'
        ,
        inputs => "someInput",
    },
    "func" => {
        template   => $function_template,
        object     => 'func',
        name       => '${100:functionName}',
        body       => "//body...",
        inputs     => "_ someInput : Type",
        returnType => "ReturnType",
    },
    "struct" => {
        template => $bracketed,
        object   => "struct",
        name     => "SomeStructName",
    },
    "class" => {
        template => $bracketed,
        object   => "class",
        name     => "SomeClassName",
    },
    "enum" => {
        template => $bracketed,
        object   => "enum",
        name     => "SomeEnumName",
    },
    "typealias" => {
        template => $type_definition,
        object   => "typealias",
        name     => "TypeName",
        value    => "OriginType",
    },
    "let" => {
        template     => $type_definition,
        object       => "let",
        name         => "variableName",
        explicitType => "DefaultType",
        value        => "//some value...",
        ,

    },
    "var" => {
        template     => $type_definition,
        object       => "var",
        name         => "variableName",
        explicitType => "DefaultType",
        value        => "//some value...",
        ,

    },

    # "XXX" => {
    #     template => $YYYY,

    # },
    # "XXX" => {
    #     template => $YYYY,

    # },
    # "XXX" => {
    #     template => $YYYY,

    # },
    # "XXX" => {
    #     template => $YYYY,

    # },
    # "XXX" => {
    #     template => $YYYY,

    # },
    # "XXX" => {
    #     template => $YYYY,

    # },

);

foreach my $keyObject ( keys %snippetHash ) {
    if ( my %snippetDetails = %{$snippetHash{$keyObject}} ) {
        make_snip( $keyObject, %snippetDetails );
    }
}
