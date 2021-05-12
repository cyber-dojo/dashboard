
# - - - - - - - - - - - - - - - - - - - - - - - -
echo_versioner_env_vars()
{
  docker run --rm cyberdojo/versioner
  # Forthcoming deployments
  #echo CYBER_DOJO_SAVER_SHA=2ae8e51362c5ad215b86d6065b0f850fae667ea8
  #echo CYBER_DOJO_SAVER_TAG=2ae8e51
  #echo CYBER_DOJO_MODEL_SHA=3fb3f3764cab60078fe5e4577a7a94b786cef308
  #echo CYBER_DOJO_MODEL_TAG=3fb3f37
}
