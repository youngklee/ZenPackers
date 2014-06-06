Regular Expression 
=====================

Breaking Regular Expressions into Readable Parts
--------------------------------------------------

You can write your regular expression so that you can
easily read them::

   cs_RX = re.compile("^"                       # BOL
                      "(jdbc:db2://)?"          # cs_prefix (jdbc:db2://)
                      "([\w.-]+)\:(\d+)"        # hostnme:port
                      "/([\w_\$\d]+)\:"         # /DB_name:
                      "user=([\w.-_@]+);"       # username=joe;
                      "password=([\w.-_@]+)"    # password=rabbits;
                      ";"                       # Final semicolon
                      "$"                       # EOL
                      )

Matching Regular Expressions by Key
--------------------------------------

To match a Regular Expression by named groups, you use the following syntax::

  Regex pattern...  (?P<varname><regex>)

An example of this is::

   import re

   CS_REGEX = re.compile(
        '^'                          # BOL
        '(?P<username>\w+)'          # Username
        '\/'                         # slash
        '(?P<password>\w+)'          # Password
        '@'                          # at-symbol
        '(?P<host>[\w.-]+)'          # Host
        ':'                          # colon
        '(?P<port>\d+)'              # Port
        '[:/]'                       # color or slash
        '(?P<instance>[\.\w_\$\d]+)' # Instance
        '$'                          # EOL
        )


Another Example: def get_engine(eng=None, extra=None)::

   if eng == none:
       pattern =  "(?p<year>[0-9]{4})(?p<month>[0-9]{2})(?p<day>[0-9]{2})_"
       pattern += "(?p<hour>[0-9]{2})(?p<minute>[0-9]{2})(?p<second>[0-9]{2})_"
       pattern += "(?p<tablename>[a-za-z_0-9.]{1,})[.](?p<kind>lock|partial|tmp)"
       if extra:
           pattern += extra
       eng = re.compile(pattern)
   return eng



   def get_match(self, filepath):
       eng = get_engine()
       match = {}
       filename = os.path.basename(filepath)
       if eng.match(filename):
           data = [m.groupdict() for m in eng.finditer(filename)][0]
           for name, value in data.iteritems():
               try:
                   match[name] = int(value)
               except:
                   match[name] = value

       return match

Basically, it looks for a filepath with the following pattern::

    <year><month><day>_<hour><minute><second>_<name>.<kind>

Examples might be: 20140122_103244_something.tmp,
'data' inside of 'get_match' holds the key:value dictionary


