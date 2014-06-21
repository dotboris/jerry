def silence_warnings
  original = $VERBOSE
  $VERBOSE = nil
  result = yield
  $VERBOSE = original
  result
end