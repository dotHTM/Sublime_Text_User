#!/usr/bin/env perl
# make_snips.pl
#   Description

use feature ':5.16';

use strict;
use warnings;

use Carp;
use Template::Liquid;

#######################################################
#                                                     #
#     ad88888ba              88                       #
#    d8"     "8b             88                       #
#    Y8,                     88                       #
#    `Y8aaaaa,   88       88 88,dPPYba,  ,adPPYba,    #
#      `"""""8b, 88       88 88P'    "8a I8[    ""    #
#            `8b 88       88 88       d8  `"Y8ba,     #
#    Y8a     a8P "8a,   ,a88 88b,   ,a8" aa    ]8I    #
#     "Y88888P"   `"YbbdP'Y8 8Y"Ybbd8"'  `"YbbdP"'    #
#                                                     #
#                                                     #
#######################################################

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
        ["snips/$someObject.sublime-snippet"],
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
            body => render(
                object => $args{object} ? $args{object} : $someObject,
                %args
            ),
            trigger => $args{trigger} ? $args{trigger} : $someObject,
            desc    => $args{desc}    ? $args{desc}    : $someObject,
        )
    );
}    ##    make_snip

#####################################################
#                                                   #
#    88b           d88            88                #
#    888b         d888            ""                #
#    88`8b       d8'88                              #
#    88 `8b     d8' 88 ,adPPYYba, 88 8b,dPPYba,     #
#    88  `8b   d8'  88 ""     `Y8 88 88P'   `"8a    #
#    88   `8b d8'   88 ,adPPPPP88 88 88       88    #
#    88    `888'    88 88,    ,88 88 88       88    #
#    88     `8'     88 `"8bbdP"Y8 88 88       88    #
#                                                   #
#                                                   #
#####################################################

my $trivial = "{{prefix}}{{object}}{{suffix}}";

my $bracketed_general = <<EOL
{{object}} \${100:{{name}}}{% if protocol_adherance %}\${200/^.+\$/ : /}\${200:{{protocol_adherance}}}{% endif %} {
\t\${900:// body ...}
} // \${100}
EOL
    ;

my $type_assignment = <<EOL
{{object}} \${100:{{name}}}{% if explicitType %}\${200/^.+\$/ : /}\${200:{{explicitType}}}{% endif %}\${900/^.+\$/ = /}\${900:{{value}}}
EOL
    ;

my $function_declaration = <<EOL
{{object}} {{ name }}(\${800:{{inputs}}}){% if returnType %}\${850/^.+\$/->/}\${850:{{returnType}}}{% endif %}{
\t\${900:{{body}}}{% if returnType %}\${850/^.+\$/
\treturn \\/\\/type.../}{% endif %}
} // {{ name }}
EOL
    ;

my $function_invocation = <<EOL
{{object}}{% if loose_input != 1 %}({% endif %}\${100:{{inputs}}}{% if loose_input != 1 %}){% endif %}{% if closureinput %}\${999/^.+\$/\{/}\${999:{{ closureinput }}}\${999/^.+\$/\}/}{% endif %}
EOL
    ;

my %snippetHash = (

## Basics
    "typealias" => {
        desc     => "Type Alias",
        template => $type_assignment,
        name     => "TypeName",
        value    => "OriginType",
    },
    "let" => {
        desc         => "Constant Variable",
        template     => $type_assignment,
        name         => "constantName",
        explicitType => "DefaultType",
        value        => "//some value...",
        ,
    },
    "var" => {
        desc         => "Mutable Variable",
        template     => $type_assignment,
        name         => "variableName",
        explicitType => "DefaultType",
        value        => "//some value...",
        ,
    },
    "func" => {
        desc       => "Subroutine",
        template   => $function_declaration,
        name       => '${100:functionName}',
        body       => "//body...",
        inputs     => "_ someInput : Type",
        returnType => "ReturnType",
    },

## Objects
    "protocol" => {
        protocol_adherance => "SomeOtherProtocol",
        desc               => "Protocol Declaration",
        template           => $bracketed_general,
        name               => "SomeProtocolName",
    },
    "struct" => {
        protocol_adherance => "SomeProtocol",
        desc               => "Value Type",
        template           => $bracketed_general,
        name               => "SomeStructName",
    },
    "class" => {
        protocol_adherance => "SomeProtocol",
        desc               => "Reference Type",
        template           => $bracketed_general,
        name               => "SomeClassName",
    },
    "init" => {
        desc         => "Object Initializer",
        template     => $function_invocation,
        closureinput => "\n\t//body...\n",
        inputs       => "_ someInput : Type",
    },

## Enums
    "enum" => {
        protocol_adherance => "SomeProtocol",
        desc               => "Enumerator",
        template           => $bracketed_general,
        name               => "SomeEnumName",
    },
    "switch" => {
        object       => "switch ",
        loose_input  => 1,
        desc         => "Switch Statement",
        template     => $function_invocation,
        closureinput =>
            "\ncase .\${802:scenario}:\n\t\${803://code...}\ndefault:\n\t\${804://code...}\n",
        inputs => "someInput",
    },
    "case" => {
        desc     => "Switch Case",
        template => $trivial,
        suffix   => " .\${900:scenario} :\n\t\${999://code...}",
    },
    "default" => {
        desc     => "Switch Case Default",
        template => $trivial,
        suffix   => " :\n\t\${999://code...}",
    },

    "extension" => {
        template           => $bracketed_general,
        desc               => "Object Extension",
        name               => "SomeObjectName",
        protocol_adherance => "SomeProtocol",

    },

    # "XXX" => {
    #     template => $YYYY,
    # },
);

foreach my $keyObject ( keys %snippetHash ) {
    if ( my %snippetDetails = %{ $snippetHash{$keyObject} } ) {
        make_snip( $keyObject, %snippetDetails );
    }
}

exit();

my $test = <<SQL;


select hello from world where foo == bar group by fizz order by buzz desc



SQL

