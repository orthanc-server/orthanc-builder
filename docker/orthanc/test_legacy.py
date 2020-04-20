import unittest
from configurator import OrthancConfigurator


class LegacyTest(unittest.TestCase):
  
  def test_default_config(self):
    c = OrthancConfigurator()
    c.mergeConfigFromDefaults()

    self.assertTrue(c.configuration["RemoteAccessAllowed"])
    self.assertTrue(c.configuration["AuthenticationEnabled"])


  def test_simple_env_vars_to_enable_plugin(self):
    c = OrthancConfigurator()
    c.mergeConfigFromEnvVar("WL_ENABLED", "true")

    self.assertIn("Worklists", c.getEnabledPlugins())


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


  def test_direct_secret(self):
    c = OrthancConfigurator()
    c.mergeConfigFromSecret("/run/secrets/PG_PASSWORD", "pg-password")

    self.assertIn("PostgreSQL", c.configuration)
    self.assertIn("PostgreSQL", c.getEnabledPlugins())
    self.assertEqual("pg-password", c.configuration["PostgreSQL"]["Password"])

  def test_indirect_secret(self):
    c = OrthancConfigurator()
    c.mergeConfigFromEnvVar("PG_PASSWORD_SECRET", "pg-password-file")
    c.mergeConfigFromSecret("/run/secrets/pg-password-file", "pg-password")

    self.assertIn("PostgreSQL", c.configuration)
    self.assertIn("PostgreSQL", c.getEnabledPlugins())
    self.assertEqual("pg-password", c.configuration["PostgreSQL"]["Password"])

if __name__ == '__main__':
    unittest.main()