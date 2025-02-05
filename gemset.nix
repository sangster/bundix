{
  dependencies = [
    "bundix"
    "guard-rspec"
    "guard-rubocop"
    "pry-byebug"
    "rake"
    "rspec"
    "rubocop"
    "rubocop-rake"
    "rubocop-rspec"
    "simplecov"
    "webmock"
    "yard"
  ];
  platforms = {
    ruby = {
      addressable = {
        dependencies = ["public_suffix"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1ypdmpdn20hxp5vwxz3zc04r5xcwqc25qszdlg41h8ghdqbllwmw";
          type = "gem";
        };
        version = "2.8.1";
      };
      ast = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
          type = "gem";
        };
        version = "2.4.2";
      };
      bundix = {
        dependencies = ["zeitwerk"];
        source = { path = ./.; type = "path"; };
        version = "3.0.0.pre.alpha";
      };
      byebug = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0nx3yjf4xzdgb8jkmk2344081gqr22pgjqnmjg2q64mj5d6r9194";
          type = "gem";
        };
        version = "11.1.3";
      };
      coderay = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
          type = "gem";
        };
        version = "1.1.3";
      };
      crack = {
        dependencies = ["rexml"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1cr1kfpw3vkhysvkk3wg7c54m75kd68mbm9rs5azdjdq57xid13r";
          type = "gem";
        };
        version = "0.4.5";
      };
      diff-lcs = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0rwvjahnp7cpmracd8x732rjgnilqv2sx7d1gfrysslc3h039fa9";
          type = "gem";
        };
        version = "1.5.0";
      };
      docile = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1lxqxgq71rqwj1lpl9q1mbhhhhhhdkkj7my341f2889pwayk85sz";
          type = "gem";
        };
        version = "1.4.0";
      };
      ffi = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1862ydmclzy1a0cjbvm8dz7847d9rch495ib0zb64y84d3xd4bkg";
          type = "gem";
        };
        version = "1.15.5";
      };
      formatador = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1l06bv4avphbdmr1y4g0rqlczr38k6r65b3zghrbj2ynyhm3xqjl";
          type = "gem";
        };
        version = "1.1.0";
      };
      guard = {
        dependencies = [
          "formatador"
          "listen"
          "lumberjack"
          "nenv"
          "notiffany"
          "pry"
          "shellany"
          "thor"
        ];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1zqy994fr0pf3pda0x3mmkhgnfg4hd12qp5bh1s1xm68l00viwhj";
          type = "gem";
        };
        version = "2.18.0";
      };
      guard-compat = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1zj6sr1k8w59mmi27rsii0v8xyy2rnsi09nqvwpgj1q10yq1mlis";
          type = "gem";
        };
        version = "1.2.1";
      };
      guard-rspec = {
        dependencies = ["guard" "guard-compat" "rspec"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1jkm5xp90gm4c5s51pmf92i9hc10gslwwic6mvk72g0yplya0yx4";
          type = "gem";
        };
        version = "4.7.3";
      };
      guard-rubocop = {
        dependencies = ["guard" "rubocop"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0lb2fgfac97lvgwqvx2gbcimyvw2a0i76x6yabik3vmmvjbdfh9h";
          type = "gem";
        };
        version = "1.5.0";
      };
      hashdiff = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1nynpl0xbj0nphqx1qlmyggq58ms1phf5i03hk64wcc0a17x1m1c";
          type = "gem";
        };
        version = "1.0.1";
      };
      json = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0nalhin1gda4v8ybk6lq8f407cgfrj6qzn234yra4ipkmlbfmal6";
          type = "gem";
        };
        version = "2.6.3";
      };
      listen = {
        dependencies = ["rb-fsevent" "rb-inotify"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "13rgkfar8pp31z1aamxf5y7cfq88wv6rxxcwy7cmm177qq508ycn";
          type = "gem";
        };
        version = "3.8.0";
      };
      lumberjack = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "06pybb23hypc9gvs2p839ildhn26q68drb6431ng3s39i3fkkba8";
          type = "gem";
        };
        version = "1.2.8";
      };
      method_source = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1pnyh44qycnf9mzi1j6fywd5fkskv3x7nmsqrrws0rjn5dd4ayfp";
          type = "gem";
        };
        version = "1.0.0";
      };
      nenv = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0r97jzknll9bhd8yyg2bngnnkj8rjhal667n7d32h8h7ny7nvpnr";
          type = "gem";
        };
        version = "0.3.0";
      };
      notiffany = {
        dependencies = ["nenv" "shellany"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0f47h3bmg1apr4x51szqfv3rh2vq58z3grh4w02cp3bzbdh6jxnk";
          type = "gem";
        };
        version = "0.1.3";
      };
      parallel = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "07vnk6bb54k4yc06xnwck7php50l09vvlw1ga8wdz0pia461zpzb";
          type = "gem";
        };
        version = "1.22.1";
      };
      parser = {
        dependencies = ["ast"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0cdjcasyg7w05kk82dqysq29f1qcf8y5sw8iak5flpxjbdil50qv";
          type = "gem";
        };
        version = "3.2.1.0";
      };
      pry = {
        dependencies = ["coderay" "method_source"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0k9kqkd9nps1w1r1rb7wjr31hqzkka2bhi8b518x78dcxppm9zn4";
          type = "gem";
        };
        version = "0.14.2";
      };
      pry-byebug = {
        dependencies = ["byebug" "pry"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1y41al94ks07166qbp2200yzyr5y60hm7xaiw4lxpgsm4b1pbyf8";
          type = "gem";
        };
        version = "3.10.1";
      };
      public_suffix = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0hz0bx2qs2pwb0bwazzsah03ilpf3aai8b7lk7s35jsfzwbkjq35";
          type = "gem";
        };
        version = "5.0.1";
      };
      rainbow = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
          type = "gem";
        };
        version = "3.1.1";
      };
      rake = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "15whn7p9nrkxangbs9hh75q585yfn66lv0v2mhj6q6dl6x8bzr2w";
          type = "gem";
        };
        version = "13.0.6";
      };
      rb-fsevent = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1zmf31rnpm8553lqwibvv3kkx0v7majm1f341xbxc0bk5sbhp423";
          type = "gem";
        };
        version = "0.11.2";
      };
      rb-inotify = {
        dependencies = ["ffi"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1jm76h8f8hji38z3ggf4bzi8vps6p7sagxn3ab57qc0xyga64005";
          type = "gem";
        };
        version = "0.10.1";
      };
      regexp_parser = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0d6241adx6drsfzz74nx1ld3394nm6fjpv3ammzr0g659krvgf7q";
          type = "gem";
        };
        version = "2.7.0";
      };
      rexml = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "08ximcyfjy94pm1rhcx04ny1vx2sk0x4y185gzn86yfsbzwkng53";
          type = "gem";
        };
        version = "3.2.5";
      };
      rspec = {
        dependencies = ["rspec-core" "rspec-expectations" "rspec-mocks"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "171rc90vcgjl8p1bdrqa92ymrj8a87qf6w20x05xq29mljcigi6c";
          type = "gem";
        };
        version = "3.12.0";
      };
      rspec-core = {
        dependencies = ["rspec-support"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0da45cvllbv39sdbsl65vp5djb2xf5m10mxc9jm7rsqyyxjw4h1f";
          type = "gem";
        };
        version = "3.12.1";
      };
      rspec-expectations = {
        dependencies = ["diff-lcs" "rspec-support"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "03ba3lfdsj9zl00v1yvwgcx87lbadf87livlfa5kgqssn9qdnll6";
          type = "gem";
        };
        version = "3.12.2";
      };
      rspec-mocks = {
        dependencies = ["diff-lcs" "rspec-support"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0sq2cc9pm5gq411y7iwfvzbmgv3g91lyf7y7cqn1lr3yf1v122nc";
          type = "gem";
        };
        version = "3.12.3";
      };
      rspec-support = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "12y52zwwb3xr7h91dy9k3ndmyyhr3mjcayk0nnarnrzz8yr48kfx";
          type = "gem";
        };
        version = "3.12.0";
      };
      rubocop = {
        dependencies = [
          "json"
          "parallel"
          "parser"
          "rainbow"
          "regexp_parser"
          "rexml"
          "rubocop-ast"
          "ruby-progressbar"
          "unicode-display_width"
        ];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0hcjyk8y8rbfzyhi3nnd3skdw6a53hq14lf4j0g2bjjfb3c5khch";
          type = "gem";
        };
        version = "1.47.0";
      };
      rubocop-ast = {
        dependencies = ["parser"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "16iabkwqhzqh3cd4pcrp0nqv4ks2whcz84csawi78ynfk12vd20a";
          type = "gem";
        };
        version = "1.27.0";
      };
      rubocop-capybara = {
        dependencies = ["rubocop"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1pz52ml0qbxgcjlmp8y0wsq8xy398n6ypkbrwfaa8zb0v7pscj6n";
          type = "gem";
        };
        version = "2.17.1";
      };
      rubocop-rake = {
        dependencies = ["rubocop"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1nyq07sfb3vf3ykc6j2d5yq824lzq1asb474yka36jxgi4hz5djn";
          type = "gem";
        };
        version = "0.6.0";
      };
      rubocop-rspec = {
        dependencies = ["rubocop" "rubocop-capybara"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1vmmin3ymgq7bhv2hl4pd0zpwawy709p816axc4vi67w61b4bij1";
          type = "gem";
        };
        version = "2.18.1";
      };
      ruby-progressbar = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1r5gnl9qz7ziyxyjl8p0lkqjblgpfs6hvgcw3ryv6fp1yyp44cj3";
          type = "gem";
        };
        version = "1.12.0";
      };
      shellany = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1ryyzrj1kxmnpdzhlv4ys3dnl2r5r3d2rs2jwzbnd1v96a8pl4hf";
          type = "gem";
        };
        version = "0.0.1";
      };
      simplecov = {
        dependencies = ["docile" "simplecov-html" "simplecov_json_formatter"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "198kcbrjxhhzca19yrdcd6jjj9sb51aaic3b0sc3pwjghg3j49py";
          type = "gem";
        };
        version = "0.22.0";
      };
      simplecov-html = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0yx01bxa8pbf9ip4hagqkp5m0mqfnwnw2xk8kjraiywz4lrss6jb";
          type = "gem";
        };
        version = "0.12.3";
      };
      simplecov_json_formatter = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0a5l0733hj7sk51j81ykfmlk2vd5vaijlq9d5fn165yyx3xii52j";
          type = "gem";
        };
        version = "0.1.4";
      };
      thor = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0inl77jh4ia03jw3iqm5ipr76ghal3hyjrd6r8zqsswwvi9j2xdi";
          type = "gem";
        };
        version = "1.2.1";
      };
      unicode-display_width = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1gi82k102q7bkmfi7ggn9ciypn897ylln1jk9q67kjhr39fj043a";
          type = "gem";
        };
        version = "2.4.2";
      };
      webmock = {
        dependencies = ["addressable" "crack" "hashdiff"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1myj44wvbbqvv18ragv3ihl0h61acgnfwrnj3lccdgp49bgmbjal";
          type = "gem";
        };
        version = "3.18.1";
      };
      webrick = {
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "1d4cvgmxhfczxiq5fr534lmizkhigd15bsx5719r5ds7k7ivisc7";
          type = "gem";
        };
        version = "1.7.0";
      };
      yard = {
        dependencies = ["webrick"];
        groups = ["development"];
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "0p1if8g9ww6hlpfkphqv3y1z0rbqnnrvb38c5qhnala0f8qpw6yk";
          type = "gem";
        };
        version = "0.9.28";
      };
      zeitwerk = {
        source = {
          remotes = ["https://rubygems.org"];
          sha256 = "028ld9qmgdllxrl7d0qkl65s58wb1n3gv8yjs28g43a8b1hplxk1";
          type = "gem";
        };
        version = "2.6.7";
      };
    };
  };
}
