#!/usr/bin/perl
# make_snips.pl
#   Description

use feature ':5.16';

use strict;
use warnings;

use Carp qw{croak};
use Data::Dumper::Concise;
$Data::Dumper::Sortkeys = 1;

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

