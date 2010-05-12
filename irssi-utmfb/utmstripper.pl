use Irssi;
use Irssi::Irc;

# strip idiotic UTM bits from URLs
sub event_send_text {
    my ($line, $server, $window) = @_;
    my $newline = $line;

    if ($line =~ /http/) { # only bother with URL lines
        if ($newline =~ /utm_/) {
            $newline =~ s!from=(.*?)(&|$)!!g;
        }
        $newline =~ s!utm_source=feedburner&!!g;
        $newline =~ s!utm_medium=feed&!!g;
        $newline =~ s!utm_campaign=(.*?)(&|$)!!g;
        $newline =~ s!utm_content=(.*?)(&|$)!!g;
        $newline =~ s!\?$!!; # remove a trailing ? if we have no CGI
    }

    $window->command("msg ".$window->{name}." $newline");
    Irssi::signal_stop();
}

Irssi::signal_add_first("send text", "event_send_text");
