/*
 * main.vala
 *
 * Copyright 2014 DasJott
 * Developer: Jott <das.jott at gmail com>
 *
 */


string m_sCreate = null;

SList<string> m_incldes = new SList<string>();

bool m_bVapi   = true;
bool m_bHeader = true;

void help(string sName)
{
  stderr.printf("\n");
  stderr.printf("Uses or creates c / vapi library (.so)\n");
  stderr.printf("\n");
  stderr.printf("usage: %s -i name | [-n] -c name\n", sName);
  stderr.printf("\n");
  stderr.printf("---- Modes: ----\n");
  stderr.printf("-i include library\n");
  stderr.printf("   library, header and vapi must have same name\n");
  stderr.printf("-c create library\n");
  stderr.printf("   library, header and vapi will have same name\n");
  stderr.printf("\n");
  stderr.printf("---- Options: ----\n");
  stderr.printf("-nv no vapi creation\n");
  stderr.printf("   if -c don't create a vapi file\n");
  stderr.printf("\n");
  stderr.printf("-nh no header creation\n");
  stderr.printf("   if -c don't create a header file\n");
  stderr.printf("\n");
  stderr.printf("NOTE: Provide name without the 'lib' prefix and any extension!\n");
  stderr.printf("Example: To include or create libfoo.so only specify foo as a name\n");
  stderr.printf("\n");
}

bool getArgs(string[] args)
{
  string sName = args[0];

  bool bCreate = false;
  bool bInclde = false;

  uint len = args.length;
  for (int i=1; i<len; ++i) {
    switch (args[i]) {
      case "?":
      case "-?":
      case "-h":
      case "--help":
      {
        help(sName);
      } break;
      case "-c": bCreate = true;  continue;
      case "-i": bInclde = true;  continue;
      default:
      {
        if (bCreate) {
          m_sCreate = args[i];
        }
        if (bInclde) {
          m_incldes.append(args[i]);
        }
      } break;
      case "-nv": m_bVapi   = false; break;
      case "-nh": m_bHeader = false; break;
    }
    bCreate = false;
    bInclde = false;
  }
  if (len < 2 || ((m_sCreate == null) && (m_incldes.length() == 0)) ) {
    help(sName);
    return false;
  }
  return true;
}

int main(string[] args)
{
  if (!getArgs(args)) {
    return 1;
  }

  if (m_sCreate != null) {
    string sCreateVapi = "";
    string sCreateHeader = "";
    if (m_bVapi) {
      sCreateVapi = " --vapi=%s.vapi".printf(m_sCreate);
    }
    if (m_bHeader) {
      sCreateHeader = " -H %s.h".printf(m_sCreate);
    }
    stdout.printf("-X -fPIC -X -shared --library=%s%s%s -o lib%s.so", m_sCreate, sCreateVapi, sCreateHeader, m_sCreate);
  }

  m_incldes.foreach( (sLib) => {
    stdout.printf(" ");
    string sLibDir = "";
    int idx = sLib.last_index_of("/");
    if (idx > 0) {
      sLibDir = " -X -I%s".printf( sLib.substring(0, idx) );
    }
    string sVapiInclude = "";
    string sVapi = sLib + ".vapi";
    if (FileUtils.test(sVapi, FileTest.EXISTS)) {
      sVapiInclude = " " + sVapi;
    }
    stdout.printf("-X lib%s.so%s%s", sLib, sLibDir, sVapiInclude);
  });
  return 0;
}
