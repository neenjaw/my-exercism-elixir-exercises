#!/usr/bin/awk -f

function left_strip (string) {
  sub(/^\s+/, "", string);
  return string;
}

function escape_double_quote (string) {
  gsub(/"/, "\\\"", string);
  return string;
}

BEGIN {
  test_count=0;
  in_describe=0;
  in_test=0;
  describe_block_count=0;
  test_block_count=0;
}

($0 ~ /^\s*$/) { next; }

($0 ~ "end" && in_test) {
  test_block_count-=1;
  if (test_block_count == 0) {
    in_test=0;
    test_count+=1;
    in_assert=0;
    assert_count=0;
  }
}

($0 ~ "assert" && in_test) {
  in_assert=1;
  assert_count+=1;
  meta[test_count]["assert_count"]=assert_count+1;
  meta[test_count]["assertions"][assert_count]="";
}

(in_test && !in_assert) {
  stripped=left_strip($0);

  if (meta[test_count]["code"] == "") {
    meta[test_count]["code"]=stripped;
  } else {
    meta[test_count]["code"]=meta[test_count]["code"] "\n" stripped;
  }
}

(in_test && in_assert) {
  stripped=left_strip($0);

  if (meta[test_count]["assertions"][assert_count] == "") {
    meta[test_count]["assertions"][assert_count]=stripped;
  } else {
    meta[test_count]["assertions"][assert_count]=meta[test_count]["assertions"][assert_count] "\n" stripped;
  }
}

($0 ~ "test") {
  in_test=1;
  assert_count=-1;
  FS="\"";
  $0=$0;
  current_test=$2;
  meta[test_count]["name"]=current_test;
  meta[test_count]["code"]="";
  meta[test_count]["assert_count"]=assert_count;
  FS=" ";
}

($0 ~ " do" && in_test) {
  test_block_count+=1;
}

($0 ~ " do" && in_describe) {
  describe_block_count+=1;
}

END {
  for (i=0; i < test_count; i+=1) {
    ORS=",";
    print "\"" meta[i]["name"] "\"";
    print "\"" escape_double_quote(meta[i]["code"]) "\"";
    print meta[i]["assert_count"];

    for (j=0; j < meta[i]["assert_count"] - 1 ; j+=1) {
      print "\"" meta[i]["assertions"][j] "\"";
    }
    ORS="\n";
    print "\"" meta[i]["assertions"][meta[i]["assert_count"] - 1] "\"";
  }
}
