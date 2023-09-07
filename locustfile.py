from locust import HttpUser, task, between
class ZaferCapstone(HttpUser):
    wait_time = between(1, 3)
    @task
    def test_homepage(self):
        self.client.verify = False
        for _ in range(10):
            response = self.client.get("/")
            if response.status_code == 200:
                self.success("Home page loaded successfully", {"status_code": response.status_code})
            else:
                self.failure("Failed to load home page", {"status_code": response.status_code})
