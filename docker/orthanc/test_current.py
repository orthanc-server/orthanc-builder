import unittest
import json
from configurator import OrthancConfigurator


class CurrentTest(unittest.TestCase):
  
  def test_default_config(self):
    c = OrthancConfigurator()
    c.mergeConfigFromDefaults()

    self.assertTrue(c.configuration["RemoteAccessAllowed"])
    self.assertTrue(c.configuration["AuthenticationEnabled"])

  def test_multiple_files(self):
    c = OrthancConfigurator()
    worklistsConfig = {
      "Worklists" : {
        "Database" : "tutu"
      }
    }
    pgConfig = {
      "PostgreSQL" : {
        "Host" : "host"
      }
    }

    c.mergeConfigFromFile(worklistsConfig, "worklists.json")
    c.mergeConfigFromFile(pgConfig, "pg.json")

    self.assertIn("Worklists", c.getEnabledPlugins())
    self.assertIn("PostgreSQL", c.getEnabledPlugins())


  def test_file_in_env_var(self):
    c = OrthancConfigurator()
    worklistsConfig = {
      "Worklists" : {
        "Database" : "tutu"
      }
    }
    configFileInString = json.dumps(worklistsConfig, indent=2)

    c.mergeConfigFromEnvVar("ORTHANC_JSON", configFileInString)

    self.assertIn("Worklists", c.getEnabledPlugins())
    self.assertEqual("tutu", c.configuration["Worklists"]["Database"])

  def test_simple_env_vars_to_enable_plugin(self):
    c = OrthancConfigurator()
    c.mergeConfigFromEnvVar("WORKLISTS_PLUGIN_ENABLED", "true")

    self.assertIn("Worklists", c.getEnabledPlugins())

  def test_file_not_overwritten_by_plugin_default(self):
    c = OrthancConfigurator()
    pgConfig = {
      "PostgreSQL" : {
        "Password" : "pg-password",
        "Host" : "host"
      }
    }
    c.mergeConfigFromFile(pgConfig, "pg.json")
    c.mergeConfigFromDefaults()

    self.assertEqual("host", c.configuration["PostgreSQL"]["Host"])
    self.assertEqual("pg-password", c.configuration["PostgreSQL"]["Password"])
    self.assertEqual("postgres", c.configuration["PostgreSQL"]["Username"])


  def test_simple_section_to_enable_plugin(self):
    c = OrthancConfigurator()
    worklistsConfig = {
      "Worklists" : {
        "Database" : "tutu"
      }
    }
    c.mergeConfigFromFile(worklistsConfig, "worklist.json")

    self.assertIn("Worklists", c.configuration)
    self.assertIn("Worklists", c.getEnabledPlugins())

  def test_python_plugin_with_root_setting(self):
    c = OrthancConfigurator()
    config = {
      "PythonScript" : "tutu.py"
    }
    c.mergeConfigFromFile(config, "config.json")

    self.assertIn("Python", c.getEnabledPlugins())


  def test_direct_secret(self):
    c = OrthancConfigurator()
    c.mergeConfigFromSecret("/run/secrets/ORTHANC__POSTGRESQL__PASSWORD", "pg-password")

    self.assertIn("PostgreSQL", c.configuration)
    self.assertIn("PostgreSQL", c.getEnabledPlugins())
    self.assertEqual("pg-password", c.configuration["PostgreSQL"]["Password"])

  def test_indirect_secret(self):
    c = OrthancConfigurator()
    c.mergeConfigFromEnvVar("ORTHANC__POSTGRESQL__PASSWORD_SECRET", "pg-password-file")
    c.mergeConfigFromSecret("/run/secrets/pg-password-file", "pg-password")

    self.assertIn("PostgreSQL", c.configuration)
    self.assertIn("PostgreSQL", c.getEnabledPlugins())
    self.assertEqual("pg-password", c.configuration["PostgreSQL"]["Password"])

  def test_gdcm_enabled_by_default(self):
    c = OrthancConfigurator()

    self.assertIn("Gdcm", c.getEnabledPlugins())

  def test_disable_gdcm_by_env_var(self):
    c = OrthancConfigurator()
    c.mergeConfigFromEnvVar("GDCM_PLUGIN_ENABLED", "false")

    self.assertNotIn("Gdcm", c.getEnabledPlugins())

if __name__ == '__main__':
    unittest.main()