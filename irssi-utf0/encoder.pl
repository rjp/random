use Irssi;
use Irssi::Irc;
use Encode qw(from_to encode decode);
use Data::Dumper;
use Text::Unidecode;

my ($noutf8win);

BEGIN {
    # would be better to set a flag or something
    $noutf8win = Irssi::window_find_name('noutf8');
    if (!$noutf8win) {
        Irssi::command("window new hide");
        Irssi::command("window name noutf8");
        $noutf8win = Irssi::window_find_name('noutf8');
    }
}

sub event_send_text {
    my ($line, $server, $window) = @_;
    if ($window->{'name'} eq 'noutf8') { # avoid UTF8 here
        $pastewin->print($line);
        my $inter = decode('utf8', $line);
        my $newline = unidecode($inter);
        $window->command("msg ".$window->{name}." $newline");
        Irssi::signal_stop();
    }
}

Irssi::signal_add_first("send text", "event_send_text");
