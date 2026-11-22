#!/usr/bin/env bash
# Проверки репозитория avoid-ai-writing-ru.
# Зависимости: bash 3.2+, find, xargs, perl 5. Запуск: bash scripts/check.sh
#
# (а) в .md/.yml/.yaml/.sh/.py/.json нет символов U+2014 (em dash) и U+2013 (en dash);
# (б) нет украинских букв U+0456 U+0457 U+0454 U+0491 и их заглавных;
# (в) у SKILL.md есть frontmatter с полями name, description, version, license;
# (г) каждый id правила из examples/ есть в SKILL.md в обратных кавычках
#     (id вида ext:<словарь>:<правило> из подключаемых словарей не сверяются);
# (д) у каждого кейса в examples/fires и examples/must-not-fire есть profile и expect.
#
# Сами запрещённые символы в этом файле записаны только escape-кодами.

set -u

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 2

errors=0
fail() { printf 'FAIL  %s\n' "$1"; errors=$((errors + 1)); }
ok()   { printf 'OK    %s\n' "$1"; }
warn() { printf 'WARN  %s\n' "$1"; }

list_text_files() {
  find . -path ./.git -prune -o -type f \
    \( -name '*.md' -o -name '*.yml' -o -name '*.yaml' -o -name '*.sh' -o -name '*.py' -o -name '*.json' \) -print0
}

# (а) длинное и среднее тире
out=$(list_text_files | xargs -0 perl -CSD -ne '
  if (/[\x{2013}\x{2014}]/) { chomp; print "  $ARGV:$.: $_\n" }
  close ARGV if eof;')
if [ -n "$out" ]; then
  fail "найдены символы U+2014/U+2013:"
  printf '%s\n' "$out"
else
  ok "нет символов U+2014/U+2013"
fi

# (б) украинские буквы
out=$(list_text_files | xargs -0 perl -CSD -ne '
  if (/[\x{0404}\x{0406}\x{0407}\x{0490}\x{0454}\x{0456}\x{0457}\x{0491}]/) { chomp; print "  $ARGV:$.: $_\n" }
  close ARGV if eof;')
if [ -n "$out" ]; then
  fail "найдены украинские буквы:"
  printf '%s\n' "$out"
else
  ok "нет украинских букв"
fi

# (в) frontmatter SKILL.md
if [ -f SKILL.md ]; then
  out=$(perl -CSD -e '
    use utf8;
    open my $f, "<", "SKILL.md" or do { print "не открывается"; exit 1 };
    my $first = <$f>;
    unless (defined $first && $first =~ /^---\s*$/) { print "нет открывающей строки ---"; exit 1 }
    my (%k, $closed);
    while (my $l = <$f>) {
      if ($l =~ /^---\s*$/) { $closed = 1; last }
      $k{$1} = 1 if $l =~ /^([A-Za-z_][A-Za-z0-9_-]*):/;
    }
    unless ($closed) { print "нет закрывающей строки ---"; exit 1 }
    my @miss = grep { !$k{$_} } qw(name description version license);
    if (@miss) { print "нет полей: @miss"; exit 1 }
    exit 0;')
  if [ $? -ne 0 ]; then
    fail "SKILL.md frontmatter: $out"
  else
    ok "SKILL.md frontmatter: name, description, version, license"
  fi
else
  warn "SKILL.md не найден, проверка frontmatter пропущена"
fi

# Файлы с кейсами
case_files=$(find examples/fires examples/must-not-fire -type f -name '*.md' 2>/dev/null | sort)
if [ -z "$case_files" ]; then
  fail "нет файлов с кейсами в examples/fires и examples/must-not-fire"
fi

# (д) структура кейсов: profile, expect, rules; expect совпадает с папкой;
# в fires каждый id из списка флагов есть в rules и наоборот.
if [ -n "$case_files" ]; then
  out=$(printf '%s\n' "$case_files" | perl -CSD -e '
    use utf8;
    my %profiles = map { $_ => 1 } qw(social blog technical-blog official personal email-friendly creative casual);
    my ($bad, $count) = (0, 0);
    my @files = map { chomp; $_ } <STDIN>;
    for my $file (@files) {
      my $want = $file =~ m{/fires/} ? "fires" : "clean";
      open my $fh, "<", $file or next;
      my @cases; my $cur;
      while (my $l = <$fh>) {
        if ($l =~ /^###\s+(\S+)/) { $cur = { id => $1, line => $., flags => {} }; push @cases, $cur; next }
        next unless $cur;
        $cur->{profile} = $1 if $l =~ /^- profile:\s*(\S+)/;
        $cur->{expect}  = $1 if $l =~ /^- expect:\s*(\S+)/;
        if ($l =~ /^- rules:\s*\[(.*)\]/) { $cur->{rules} = { map { $_ => 1 } grep { length } map { s/^\s+|\s+$//gr } split /,/, $1 } }
        $cur->{flags}{$1} = 1 if $l =~ /^- `([a-z0-9:-]+)` \((?:P0|P1|P2|совет)\):/;
      }
      for my $c (@cases) {
        $count++;
        my $where = "$file:$c->{line} ($c->{id})";
        my @p;
        if (!defined $c->{profile})               { push @p, "нет profile" }
        elsif (!$profiles{$c->{profile}})         { push @p, "неизвестный profile \"$c->{profile}\"" }
        if (!defined $c->{expect})                { push @p, "нет expect" }
        elsif ($c->{expect} ne $want)             { push @p, "expect: $c->{expect}, для этой папки нужен $want" }
        if (!$c->{rules} || !%{ $c->{rules} })    { push @p, "нет rules" }
        if ($want eq "fires" && $c->{rules}) {
          my @nf = grep { !$c->{flags}{$_} } sort keys %{ $c->{rules} };
          my @nr = grep { !$c->{rules}{$_} } sort keys %{ $c->{flags} };
          push @p, "в rules без флага: @nf" if @nf;
          push @p, "флаг не указан в rules: @nr" if @nr;
          push @p, "нет ни одного флага" unless %{ $c->{flags} };
        }
        if (@p) { $bad++; print "  $where: ", join("; ", @p), "\n" }
      }
    }
    print "CASES $count\n";
    exit($bad ? 1 : 0);')
  status=$?
  total=$(printf '%s\n' "$out" | sed -n 's/^CASES //p')
  details=$(printf '%s\n' "$out" | grep -v '^CASES ')
  if [ $status -ne 0 ]; then
    fail "структура кейсов (всего $total):"
    printf '%s\n' "$details"
  else
    ok "структура кейсов: $total кейсов, у всех есть profile, expect, rules"
  fi
fi

# (г) id правил из examples есть в SKILL.md
if [ -n "$case_files" ]; then
  if [ -f SKILL.md ]; then
    out=$(printf '%s\n' "$case_files" | perl -CSD -e '
    use utf8;
      local $/;
      open my $s, "<", "SKILL.md" or exit 2;
      my $skill = <$s>;
      my %ids;
      for my $file (map { chomp; $_ } split /\n/, do { local $/; <STDIN> }) {
        open my $fh, "<", $file or next;
        my $text = <$fh>;
        while ($text =~ /^- rules:\s*\[(.*)\]/mg) { $ids{ s/^\s+|\s+$//gr } = 1 for grep { /\S/ } split /,/, $1 }
        while ($text =~ /^- `([a-z0-9:-]+)` \(/mg) { $ids{$1} = 1 }
      }
      my @bad_ext = grep { /^ext:/ && !/^ext:[a-z0-9-]+:[a-z0-9-]+$/ } sort keys %ids;
      my @miss = grep { !/^ext:/ && index($skill, "`$_`") < 0 } sort keys %ids;
      push @miss, map { "$_(неверный формат ext)" } @bad_ext;
      print scalar(keys %ids), "\n";
      print "$_\n" for @miss;
      exit(@miss ? 1 : 0);')
    status=$?
    n=$(printf '%s\n' "$out" | head -n 1)
    miss=$(printf '%s\n' "$out" | tail -n +2 | tr '\n' ' ')
    if [ $status -ne 0 ]; then
      fail "id правил из examples нет в SKILL.md: $miss"
    else
      ok "все $n id правил из examples есть в SKILL.md"
    fi
  else
    warn "SKILL.md не найден, сверка id правил пропущена"
  fi
fi

echo
if [ "$errors" -gt 0 ]; then
  echo "Итог: ошибок $errors"
  exit 1
fi
echo "Итог: ошибок нет"
exit 0
