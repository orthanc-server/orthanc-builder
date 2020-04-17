import unittest
from configurator import OrthancConfigurator


class LegacyTest(unittest.TestCase):
  
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


if __name__ == '__main__':
    unittest.main()