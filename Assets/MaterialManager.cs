using UnityEngine;
using UnityEngine.UI;

public class MaterialManager : MonoBehaviour
{
	[Header("References")]
	[SerializeField] private Text text;
	[SerializeField] private Material material1, material2;

	[Header("Settings")]
	[SerializeField] private Setup scene;
	[SerializeField] private float duration;
	private float _timer;
	private bool _isIncreasing;

	private void Update()
	{
		if (_isIncreasing)
		{
			_timer += Time.deltaTime;
			if (_timer > duration)
			{
				_isIncreasing = false;
				_timer = duration;
			}
		}
		else
		{
			_timer -= Time.deltaTime;
			if (_timer < 0f)
			{
				_isIncreasing = true;
				_timer = 0f;
			}
		}

		float lerpVal = _timer / duration;

		if (scene == Setup.Scene1)
		{
			Handle1VariableEffect(lerpVal, material1);
			Handle2VariablesEffect(lerpVal, material2);
		}
		else
		{
			Handle2VariablesEffect(lerpVal, material1);
			Handle2VariablesEffect(lerpVal, material2);
		}

		text.text = "Lerp Val = " + lerpVal;
	}

	private void Handle1VariableEffect(float lerpVal, Material mat)
	{
		mat.SetFloat("_Burn", lerpVal);
	}

	private void Handle2VariablesEffect(float lerpVal, Material mat)
	{
		if (lerpVal < 0.5f)
		{
			mat.SetFloat("_Burn", lerpVal * 2f);
		}
		else
		{
			mat.SetFloat("_Dissolve", lerpVal * 2f - 1f);
		}
	}

	enum Setup
	{
		Scene1, Scene2
	}
}